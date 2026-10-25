from hashlib import sha256
from ipaddress import IPv6Address, IPv6Network

from octodns.processor.base import BaseProcessor
from octodns.record import Record
from octodns.record.base import ValueMixin
from octodns.record.target import _TargetValue
from octodns.zone import Zone


class AnameRecord(ValueMixin, Record):
    _type = "ANAME"
    _value_type = _TargetValue
Record.register_type(AnameRecord)


class ResolveAname(BaseProcessor):
    def process_source_zone(self, zone, sources, lenient=False):
        lenient = self.lenient or lenient
        provider = sources[0]

        for alias in zone.records:
            if alias._type != "ANAME":
                continue

            fqdn = alias.value.lower()
            zone_name = next((name for name in sorted(
                provider.list_zones(), key=len, reverse=True
            ) if fqdn == name or fqdn.endswith(f".{name}")), None)
            if zone_name is None:
                raise ValueError(f"ANAME target {fqdn} is outside local YAML zones")

            source = zone
            if zone_name != zone.name:
                source = Zone(zone_name, [])
                provider.populate(source, lenient=lenient)
                for cls in (GenerateIPv6, SplitDualStack):
                    processor = cls(self.id)
                    processor.lenient = lenient
                    processor.process_source_zone(source, sources, lenient=lenient)

            records = [r for r in source.records if r.fqdn == fqdn]
            if not records:
                raise ValueError(f"ANAME target {fqdn} has no records")
            if any(r._type == "ANAME" for r in records):
                raise ValueError(f"ANAME target {fqdn} cannot be another ANAME")

            zone.remove_record(alias)
            for record in records:
                # Keep the alias TTL; do not inherit generation/PTR metadata.
                data = record.data.copy()
                data.update(type=record._type, ttl=alias.ttl)
                data.pop("octodns", None)
                zone.add_record(Record.new(
                    zone, alias.name, data, source=provider, lenient=lenient,
                ), lenient=lenient)
        return zone


class GenerateIPv6(BaseProcessor):
    def process_source_zone(self, desired, sources, lenient=False):
        lenient = self.lenient or lenient
        for record in desired.records:
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
