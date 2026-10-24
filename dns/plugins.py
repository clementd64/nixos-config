from octodns.processor.base import BaseProcessor
from octodns.record import Record


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
