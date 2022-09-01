

locals {
  project_id          = "project-test0001"
  service_account_one = "service-account1"
  service_account_one_email = format(
    "%s@%s.iam.gserviceaccount.com", local.service_account_one, local.project_id
  )
  sa_email    = "service_account3_differentproject@project-test0002.iam.gserviceaccount.com"
  group_email = "google-group@organization.com"
  user_email  = "user_email@organization.com"
}

resource "google_service_account" "gsaone" {
  account_id = local.service_account_one
  project    = local.project_id
}

# module "project_iam" {
#   source  = "github.com/mineiros-io/terraform-google-project-iam.git?ref=v0.2.0"
#   project = local.project_id
#   role    = "roles/storage.objectAdmin"
#   members = [
#     format("serviceAccount:%s", local.service_account_one_email)
#   ]
# }

# module "gsa_iam_serviceAccountUser" {
#   source             = "github.com/mineiros-io/terraform-google-service-account-iam?ref=v0.0.4"
#   service_account_id = google_service_account.gsaone.id
#   role               = "roles/iam.serviceAccountUser"
#   members = [
#     "group:${local.group_email}",
#     "serviceAccount:${local.sa_email}",
#     "user:${local.user_email}",
#   ]
# }

# module "gsa_iam_serviceAccountTokenCreator" {
#   source             = "github.com/mineiros-io/terraform-google-service-account-iam?ref=v0.0.4"
#   service_account_id = google_service_account.gsaone.id
#   role               = "roles/iam.serviceAccountTokenCreator"
#   members = [
#     "group:${local.group_email}",
#     "serviceAccount:${local.sa_email}",
#     "user:${local.user_email}",
#   ]
# }

module "project_iam" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  version  = "7.4.1"
  projects = [local.project_id]
  mode     = "additive"
  bindings = {
    "roles/storage.objectAdmin" = [
      format("serviceAccount:%s", local.service_account_one_email)
    ]
    "roles/appengine.appAdmin" = [
      "serviceAccount:${local.sa_email}",
    ]
  }
}

module "service_account_iam_binding" {
  source           = "terraform-google-modules/iam/google//modules/service_accounts_iam"
  version          = "7.4.1"
  service_accounts = [local.service_account_one_email]
  project          = local.project_id
  mode             = "additive"
  bindings = {
    "roles/iam.serviceAccountKeyAdmin" = [
      "serviceAccount:${local.sa_email}",
      "group:${local.group_email}",
      "user:${local.user_email}",
    ]
    "roles/iam.serviceAccountTokenCreator" = [
      "serviceAccount:${local.sa_email}",
      "group:${local.group_email}",
      "user:${local.user_email}",
    ]
  }
}
