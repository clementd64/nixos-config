"""Receive signed Miniflux webhooks and send through Synapse's module API.

Setup on flamii:
  * Enable Settings > Integrations > Webhook in Miniflux, with URL
    https://matrix.dubreuil.dev/_synapse/client/miniflux/webhook
  * In hosts/flamii/apps/secrets.json (using sops), set synapse.miniflux to:
    {"room_id": "!ROOM:dubreuil.dev", "webhook_secret": "SECRET_FROM_MINIFLUX"}
  * Deploy and restart Synapse to reload credentials. The module creates the
    passwordless @miniflux:dubreuil.dev account; invite it to that unencrypted
    room. It accepts the invitation when the first notification arrives.

Configuration is validated when the module loads. Only new_entries events
are delivered. Delivery failures return 502, but there is no persistent
queue or deduplication: replaying a signed webhook can duplicate notifications.
"""

import hashlib
import hmac
import json
import logging
from html import escape
from pathlib import Path

from twisted.internet.defer import ensureDeferred
from twisted.web.resource import Resource
from twisted.web.server import NOT_DONE_YET

logger = logging.getLogger(__name__)
MAX_BODY = 2 * 1024 * 1024


class MinifluxWebhook(Resource):
    isLeaf = True

    @staticmethod
    def parse_config(config):
        return config

    def __init__(self, config, api):
        super().__init__()
        self.api = api
        settings = json.loads(Path(config["config_file"]).read_text())
        self.secret = settings.get("webhook_secret", "")
        self.room = settings.get("room_id", "")

        if not isinstance(self.secret, str) or not self.secret:
            raise ValueError("Miniflux webhook_secret must be a nonempty string")
        if not isinstance(self.room, str) or not self.room.startswith("!"):
            raise ValueError("Miniflux room_id must be a Matrix room ID")

        self.sender = api.get_qualified_user_id("miniflux")
        api.delayed_background_call(0, self.initialize_bot)

    async def initialize_bot(self):
        if await self.api.get_userinfo_by_id(self.sender) is None:
            await self.api.register_user("miniflux", displayname="Miniflux")

    def render_POST(self, request):
        body = request.content.read(MAX_BODY + 1)
        if len(body) > MAX_BODY:
            request.setResponseCode(413)
            return b"Payload too large\n"

        signature = request.getHeader("X-Miniflux-Signature") or ""
        expected = hmac.new(self.secret.encode(), body, hashlib.sha256).hexdigest()
        if not hmac.compare_digest(expected.encode(), signature.encode()):
            request.setResponseCode(403)
            return b"Invalid signature\n"

        try:
            payload = json.loads(body)
            if not isinstance(payload, dict):
                raise ValueError()

            if payload.get("event_type") != "new_entries":
                request.setResponseCode(204)
                return b""

            feed, entries = payload["feed"]["title"], payload["entries"]
            if not isinstance(feed, str) or not isinstance(entries, list):
                raise ValueError()

            messages = []
            for entry in entries:
                title, url = entry["title"], entry["url"]
                if not isinstance(title, str) or not isinstance(url, str):
                    raise ValueError()
                messages.append({
                    "msgtype": "m.text",
                    "body": f"{feed[:512]}\n{title[:2048]}\n{url[:4096]}",
                    "format": "org.matrix.custom.html",
                    "formatted_body": (
                        f'{escape(feed[:512])}<br>'
                        f'<a href="{escape(url[:4096], quote=True)}">'
                        f'{escape(title[:2048])}</a>'
                    ),
                })

        except (ValueError, KeyError, TypeError, UnicodeDecodeError):
            request.setResponseCode(400)
            return b"Invalid Miniflux payload\n"

        ensureDeferred(self.deliver(request, messages))
        return NOT_DONE_YET

    async def deliver(self, request, messages):
        try:
            if messages:
                # Accept invitation
                await self.api.update_room_membership(self.sender, self.sender, self.room, "join")

                encryption = await self.api.get_state_events_in_room(self.room, [("m.room.encryption", "")])
                if list(encryption):
                    raise ValueError("Miniflux requires an unencrypted notification room")

                for message in messages:
                    await self.api.create_and_send_event_into_room({
                        "type": "m.room.message",
                        "room_id": self.room,
                        "sender": self.sender,
                        "content": message,
                    })

            code, response = 204, b""
        except Exception:
            logger.exception("Miniflux notification delivery failed")
            code, response = 502, b"Matrix delivery failed\n"

        if not request.finished:
            request.setResponseCode(code)
            request.write(response)
            request.finish()
