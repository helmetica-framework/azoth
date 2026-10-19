{{/*
  Lets Prometheus reach the instance to scrape its metrics. Prometheus runs in the
  namespace labelled `helmetica.io/monitoring: system`, and every port is open to it, so a
  reagent doesn not need to know which port its exporter listens on.
*/}}
{{- define "azoth.monitoring.networkpolicy" -}}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-monitoring
  labels:
    {{- include "azoth.labels" . | nindent 4 }}
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          helmetica.io/monitoring: system
{{- end }}
