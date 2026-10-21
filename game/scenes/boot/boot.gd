extends Control
## Foundation screen only; no farm, accounts, rewards or network calls.


func _ready() -> void:
	%Status.text = tr("Foundation ready") + " · " + App.environment
	%Details.text = tr("G0.1 bootstrap / G0.2 asset audit\nSee docs/ASSET_AUDIT_REPORT.md\nNo gameplay in this build.")
