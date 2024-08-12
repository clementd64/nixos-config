{ lib }: {
  manifests = {
    namespace = name: {
      apiVersion = "v1";
      kind = "Namespace";
      metadata = {
        name = name;
      };
    };
  };

  toMultiYAML = manifests: lib.concatMapStringsSep "\n---\n" (value: builtins.toJSON value) manifests;
}
