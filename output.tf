output "application_ids" {
  value = {
    for app in azuread_application.app-registrations :
    app.name => app.application_id
  }
}
