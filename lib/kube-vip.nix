{ writeText, k8s }:
let
  generateYAML = {
    version,
    affinity ? {},
    prometheusServer ? ":2112",
    resources ? {},
  }: k8s.toMultiYAML [
    {
      apiVersion = "v1";
      kind = "ServiceAccount";
      metadata = {
        name = "kube-vip";
        namespace = "kube-system";
      };
    }

    {
      apiVersion = "rbac.authorization.k8s.io/v1";
      kind = "ClusterRole";
      metadata = {
        name = "system:kube-vip-role";
      };
      rules = [
        {
          apiGroups = [""];
          resources = ["services/status"];
          verbs = ["update"];
        }
        {
          apiGroups = [""];
          resources = ["services" "endpoints"];
          verbs = ["list" "get" "watch" "update"];
        }
        {
          apiGroups = [""];
          resources = ["nodes"];
          verbs = ["list" "get" "watch" "update" "patch"];
        }
        {
          apiGroups = ["coordination.k8s.io"];
          resources = ["leases"];
          verbs = ["list" "get" "watch" "update" "create"];
        }
        {
          apiGroups = ["discovery.k8s.io"];
          resources = ["endpointslices"];
          verbs = ["list" "get" "watch" "update"];
        }
      ];
    }

    {
      kind = "ClusterRoleBinding";
      apiVersion = "rbac.authorization.k8s.io/v1";
      metadata = {
        name = "system:kube-vip-binding";
      };
      roleRef = {
        apiGroup = "rbac.authorization.k8s.io";
        kind = "ClusterRole";
        name = "system:kube-vip-role";
      };
      subjects = [
        {
          kind = "ServiceAccount";
          name = "kube-vip";
          namespace = "kube-system";
        }
      ];
    }

    {
      apiVersion = "apps/v1";
      kind = "DaemonSet";
      metadata = {
        labels = {
          "app.kubernetes.io/name" = "kube-vip-ds";
        };
        name = "kube-vip-ds";
        namespace = "kube-system";
      };
      spec = {
        selector = {
          matchLabels = {
            "app.kubernetes.io/name" = "kube-vip-ds";
          };
        };
        template = {
          metadata = {
            labels = {
              "app.kubernetes.io/name" = "kube-vip-ds";
            };
          };
          spec = {
            affinity = affinity;
            containers = [
              {
                args = ["manager"];
                # TODO: arguments
                env = [
                  {
                    name = "vip_arp";
                    value = "true";
                  }
                  {
                    name = "lb_enable";
                    value = "true";
                  }
                  {
                    name = "port";
                    value = "6443";
                  }
                  {
                    name = "vip_nodename";
                    valueFrom = {
                      fieldRef = {
                        fieldPath = "spec.nodeName";
                      };
                    };
                  }
                  {
                    name = "vip_interface";
                    value = "enp7s0";
                  }
                  {
                    name = "vip_cidr";
                    value = "32";
                  }
                  {
                    name = "cp_enable";
                    value = "true";
                  }
                  {
                    name = "cp_namespace";
                    value = "kube-system";
                  }
                  {
                    name = "vip_leaderelection";
                    value = "true";
                  }
                  {
                    name = "vip_leasename";
                    value = "plndr-cp-lock";
                  }
                  {
                    name = "vip_leaseduration";
                    value = "5";
                  }
                  {
                    name = "vip_renewdeadline";
                    value = "3";
                  }
                  {
                    name = "vip_retryperiod";
                    value = "1";
                  }
                  {
                    name = "address";
                    value = "10.0.0.200";
                  }
                  {
                    name = "prometheus_server";
                    value = prometheusServer;
                  }
                ];
                image = "ghcr.io/kube-vip/kube-vip:${version}";
                imagePullPolicy = "IfNotPresent";
                name = "kube-vip";
                resources = resources;
                securityContext = {
                  capabilities = {
                    add = [
                      "NET_ADMIN"
                      "NET_RAW"
                    ];
                  };
                };
              }
            ];
            hostNetwork = true;
            serviceAccountName = "kube-vip";
            tolerations = [
              {
                effect = "NoSchedule";
                operator = "Exists";
              }
              {
                effect = "NoExecute";
                operator = "Exists";
              }
            ];
          };
        };
      };
    }
  ];

in {
  inherit generateYAML;

  generate = args: writeText "kube-vip.yaml" generateYAML args;

  controlPlaneAffinity = {
    nodeAffinity = {
      requiredDuringSchedulingIgnoredDuringExecution = {
        nodeSelectorTerms = [
          {
            matchExpressions = [
              {
                key = "node-role.kubernetes.io/control-plane";
                operator = "Exists";
              }
            ];
          }
          {
            matchExpressions = [
              {
                key = "node-role.kubernetes.io/master";
                operator = "Exists";
              }
            ];
          }
        ];
      };
    };
  };
}