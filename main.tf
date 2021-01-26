resource "azuread_application" "app-registrations" {
  for_each = {
    for filename in fileset("${path.module}/apps", "**") :
    filename => yamldecode(file("${path.module}/apps/${filename}"))
  }
  name       = each.value["name"]
  homepage   = each.value["homepage"]
  reply_urls = each.value["reply_urls"]

  public_client = tobool(each.value["public_client"])
  type          = "native"

  dynamic "oauth2_permissions" {
    for_each = each.value["oauth2_permissions"]
    content {
      admin_consent_description  = oauth2_permissions.value["admin_consent_description"]
      admin_consent_display_name = oauth2_permissions.value["admin_consent_display_name"]
      is_enabled                 = true
      type                       = "User"
      user_consent_description   = oauth2_permissions.value["user_consent_description"]
      user_consent_display_name  = oauth2_permissions.value["user_consent_display_name"]
      value                      = oauth2_permissions.value["scope_name"]
    }
  }

  group_membership_claims = "SecurityGroup"
  optional_claims {
    access_token {
      name = "groups"
    }
  }

  dynamic "required_resource_access" {
    for_each = each.value["required_resources_access"]
    content {
      resource_app_id = required_resource_access.value["resource_app_id"]
      dynamic "resource_access" {
        for_each = required_resource_access.value["resource_access"]
        content {
          id   = resource_access.value["id"]
          type = resource_access.value["type"]
        }
      }
    }
  }

  provisioner "local-exec" {
    # Must be used because the terraform providers uses the legacy Azure AD Graph API which dies not support the SPA feature for auth code flow with PKCE
    command = "az rest --method PATCH --uri 'https://graph.microsoft.com/v1.0/applications/${self.object_id}' --headers 'Content-Type=application/json' --body '{\"spa\":{\"redirectUris\":[\"http://localhost:4200/index.html\"]}}'"
  }
}

