/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  # service_accounts    = [
  #   "service_account1",
  #   "service_account2"
  # ]
  service_account_one = "service_account1"
  service_account_two = "service_account2"
  project_id          = "project-test0001"
  sa_email            = "service_account3_differentproject@project-test0001.iam.gserviceaccount.com"
  group_email         = "google-group@organization.com"
  user_email          = "user_email@organization.com"
}

# resource "google_service_account" "service_accounts" {
#   for_each = toset( local.service_accounts )
#   account_id = each.key
# }

resource "google_service_account" "service_account_one" {
  account_id = local.service_account_one
  project    = local.project_id
}

resource "google_service_account" "service_account_two" {
  account_id = local.service_account_one
  project    = local.project_id
}

/******************************************
  Module service_account_iam_binding calling
 *****************************************/
module "service_account_iam_binding" {
  source = "terraform-google-modules/iam/google//service_accounts_iam"

  # service_accounts = local.service_accounts
  service_accounts = [local.service_account_one, local.service_account_two]
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
