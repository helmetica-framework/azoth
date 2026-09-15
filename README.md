# Azoth

The alchemists' universal solvent, present in every operation.

## Library Chart for Helmetica Reagents

Azoth holds the templates every reagent renders on top of its service: the backup policy,
the network seal, the maintenance window and the credentials arcanum, plus the shared
helpers behind them. A reagent depends on it and includes it in one line, so a fix here
reaches every reagent on the next version bump instead of being copied once at scaffold
time and left to rot.

Reagents are scaffolded from [ferment](https://github.com/helmetica-framework/ferment),
which carries the dependency and the include below. Nothing here needs to be wired up by
hand in a new reagent.

## Using it

```yaml
# Chart.yaml
dependencies:
  - name: azoth
    version: 0.1.0
    repository: oci://ghcr.io/helmetica-framework
```

```yaml
# templates/azoth.yaml
{{- include "azoth.all" . }}
```

`azoth.all` renders every framework resource whose `enabled` flag is set.

| Template | Renders |
| -------- | ------- |
| `azoth.all` | everything below, each gated by its `enabled` value |
| `azoth.credentials` | `Arcanum`, from `credentials.valueMapping` |
| `azoth.seal` | `Seal`, from `network` |
| `azoth.maintenance` | `Maintenance`, from `maintenance` |
| `azoth.backuppolicy` | `BackupPolicy`, from `backup` |

Helpers: `azoth.name`, `azoth.fullname`, `azoth.chart`, `azoth.labels`,
`azoth.selectorLabels`, `azoth.nightlySchedule`. They are called with the reagent's root
context, so they name and label the reagent, not this chart.

## Testing

Nothing in a library chart renders on its own, so `just test` lints the chart and runs the
unit tests (helm-unittest, installed by the recipe if missing) against `test/fixture`, a
small application chart that includes `azoth.all` and carries no values of its own. No
cluster needed.
