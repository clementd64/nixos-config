prev: final:
(import ../pkgs { inherit (final) callPackage; }) // {
  patroni = final.patroni.override {
    extras = [
      "etcd3"
      "psycopg3"
      "systemd"
    ];
  };
}
