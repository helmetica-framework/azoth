{{/*
  Every template in here is called with the reagent's root context, so `.Chart` is the
  reagent's own chart and the names and labels below come out as the reagent's.
*/}}

{{/*
Name of the chart.
*/}}
{{- define "azoth.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
A fully qualified name for resources this chart adds on top of the service. Truncated at
63 chars, the limit on most kubernetes name fields (DNS naming spec). The chart name is
only appended when the release name does not already carry it.
*/}}
{{- define "azoth.fullname" -}}
{{- $name := .Chart.Name }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Chart name and version, as used by the chart label.
*/}}
{{- define "azoth.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels. Every resource azoth renders carries these.
*/}}
{{- define "azoth.labels" -}}
helm.sh/chart: {{ include "azoth.chart" . }}
{{ include "azoth.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels. The subset that is stable across upgrades, for anything selecting pods
of this release.
*/}}
{{- define "azoth.selectorLabels" -}}
app.kubernetes.io/name: {{ include "azoth.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
A daily cron expression somewhere between 22:00 and 06:00, for a backup that has not been
given a schedule of its own. Takes a seed string and hashes it, so the time is the same on
every render of an instance, and two instances rarely share a minute. Rendering a fresh
random time instead would move the schedule on every reconcile.
*/}}
{{- define "azoth.nightlySchedule" -}}
{{- $seed := adler32sum . | int64 }}
{{- $minute := mod $seed 60 }}
{{- $hour := mod (add 22 (mod (div $seed 60) 8)) 24 }}
{{- printf "%d %d * * *" $minute $hour }}
{{- end }}
