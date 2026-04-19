package terraform.azure.tags

required_tags := {"environment", "owner", "cost_center"}

deny[msg] {
  some rc
  rc := input.resource_changes[_]
  rc.mode == "managed"

  tags := object.get(rc.change.after, "tags", {})

  some tag
  tag := required_tags[_]

  not tags[tag]

  msg := sprintf("Missing required tag: %s", [tag])
}
