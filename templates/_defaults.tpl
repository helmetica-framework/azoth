{{/*
  What azoth renders when the reagent's values.yaml says nothing: nothing. A section is
  rendered only where the reagent asks for it, so a knob added in a later azoth stays off
  until the reagent picks it up. The rest of each section is the shape the reagent inherits
  once it does; the knob becomes settable on the claim as soon as it is in the reagent's
  own values.yaml, which is the file chrysopoeia generates the CRD from.
*/}}
{{- define "azoth.defaults" -}}
backup:
  enabled: false
  mode: Schedule
  schedule:
    backup: ""
    prune: ""
    check: ""
  bucketClassName: ""
  bucketAccessClassName: ""
  retention:
    keepLast: 0
    keepHourly: 0
    keepDaily: 0
    keepWeekly: 0
    keepMonthly: 0
    keepYearly: 0
network:
  enabled: false
  allowedNamespaces: []
  allowAllNamespaces: false
maintenance:
  enabled: false
  window: ""
  suspend: false
{{- end }}

{{/*
The reagent's values with the defaults above filled in underneath. Every template here
reads its values through this rather than off `.Values` directly.
*/}}
{{- define "azoth.values" -}}
{{- mustMergeOverwrite (fromYaml (include "azoth.defaults" .)) .Values | toYaml -}}
{{- end }}
