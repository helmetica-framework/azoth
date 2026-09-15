{{/*
  Asking ampulla to back this service up. The policy is the whole contract between the
  reagent and the backup controller: ampulla provisions a bucket for it, and in mode
  Schedule backs up every persistent volume in this namespace. Nothing else in the
  framework is involved.
*/}}
{{- define "azoth.backuppolicy" -}}
{{- $backup := (fromYaml (include "azoth.values" .)).backup -}}
apiVersion: backups.helmetica.io/v1
kind: BackupPolicy
metadata:
  name: {{ .Release.Name }}
  labels:
    {{- include "azoth.labels" . | nindent 4 }}
spec:
  {{- /* Schedules and retention are ampulla's business in mode Schedule only. */}}
  {{- $scheduled := eq $backup.mode "Schedule" }}
  mode: {{ $backup.mode }}
  {{- if $scheduled }}
  {{- /*
    Backups belong in the night. Without a schedule of its own the instance gets a
    generated one rather than the controller's default of `@daily-random`, which is free
    to pick the middle of the afternoon.
  */}}
  schedule:
    backup: {{ $backup.schedule.backup | default (include "azoth.nightlySchedule" (printf "%s/%s" .Release.Namespace .Release.Name)) | quote }}
    {{- /* Prune and check are weekly jobs; empty leaves them to the controller. */}}
    {{- with $backup.schedule.prune }}
    prune: {{ . | quote }}
    {{- end }}
    {{- with $backup.schedule.check }}
    check: {{ . | quote }}
    {{- end }}
    {{- end }}
  {{- with $backup.bucketClassName }}
  bucketClassName: {{ . | quote }}
  {{- end }}
  {{- with $backup.bucketAccessClassName }}
  bucketAccessClassName: {{ . | quote }}
  {{- end }}
  {{- if $scheduled }}
  {{- /*
    Only the retention values that were actually set. An empty `retention:` key is YAML
    null, which the API rejects as "must be of type object", and a zero here would read as
    "keep none" when it means "take the controller's default".
  */}}
  {{- $retention := dict }}
  {{- range $key, $value := $backup.retention }}
    {{- if $value }}
      {{- $_ := set $retention $key $value }}
    {{- end }}
  {{- end }}
  {{- with $retention }}
  retention:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- end }}
{{- end }}
