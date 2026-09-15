{{/*
  Everything the framework renders on top of a service. A reagent includes this one
  template, so a resource added in a later azoth reaches every reagent on the next bump
  without anyone editing a chart.
*/}}
{{- define "azoth.all" -}}
{{- $values := fromYaml (include "azoth.values" .) }}
{{- /*
  The parentheses keep a section that was set to null off rather than a nil pointer, so
  `network: ~` in a reagent reads the same as `network.enabled: false`.
*/}}
{{- if ($values.network).enabled }}
---
{{ include "azoth.seal" . }}
{{- end }}
{{- if ($values.maintenance).enabled }}
---
{{ include "azoth.maintenance" . }}
{{- end }}
{{- if ($values.backup).enabled }}
---
{{ include "azoth.backuppolicy" . }}
{{- end }}
{{- end }}
