package terraform.azure.tags

import rego.v1

required_tags := {"environment", "owner", "cost_center"}

deny contains msg if {
  some rc in input.resource_changes
  rc.mode == "managed"

  tags := object.get(rc.change.after, "tags", {})

  some tag in required_tags
  not object.get(tags, tag, "")

  msg := sprintf("Missing required tag: %s", [tag])
}
