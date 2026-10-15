import json

from twisted.web.resource import Resource


class FederationDelegation(Resource):
    isLeaf = True

    @staticmethod
    def parse_config(config):
        return config

    def __init__(self, config, module_api):
        super().__init__()
        self.response = json.dumps({"m.server": config["server"]}).encode("utf-8")

    def render_GET(self, request):
        request.setHeader(b"Content-Type", b"application/json")
        return self.response
