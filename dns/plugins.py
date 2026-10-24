from hashlib import sha256
from ipaddress import IPv6Address, IPv6Network

from octodns.processor.base import BaseProcessor
from octodns.record import Record


class GenerateIPv6(BaseProcessor):
    def process_source_zone(self, desired, sources, lenient=False):
        lenient = self.lenient or lenient
        for record in list(desired.records):
            if record._type != "AAAA":
                continue

            generate = record.data.get("octodns", {}).get("generate_ipv6", False)
            if generate is False:
                continue
            if generate is True:
                hostname = record.name.split(".")[0]
            elif isinstance(generate, str) and generate:
                hostname = generate
            else:
                raise ValueError("generate_ipv6 must be true, false, or a hostname")
            if not hostname:
                raise ValueError("generate_ipv6 requires a hostname for apex records")

            data = record.data.copy()
            data["type"] = "AAAA"

            digest = sha256(hostname.encode("utf-8")).hexdigest()
            interface_id = int(digest[:16], 16)

            prefixes = data.pop("values", None)
            if prefixes is None:
                prefixes = [data.pop("value")]
            data["values"] = []
            for prefix in prefixes:
                network = IPv6Network(f"{prefix}/64")
                address = IPv6Address(int(network.network_address) | interface_id)
                data["values"].append(str(address))

            desired.add_record(Record.new(
                desired,
                record.name,
                data,
                source=record.source,
                lenient=lenient,
            ), replace=True, lenient=lenient)

        return desired


class SplitDualStack(BaseProcessor):
    def process_source_zone(self, desired, sources, lenient=False):
        lenient = self.lenient or lenient
        for record in desired.records:
            family = {"A": "v4", "AAAA": "v6"}.get(record._type)
            if family is None or not record.name.endswith(".h"):
                continue

            data = record.data.copy()
            data["type"] = record._type
            desired.add_record(Record.new(
                desired,
                f"{record.name[:-2]}.{family}.h",
                data,
                source=record.source,
                lenient=lenient,
            ), lenient=lenient)

        return desired
