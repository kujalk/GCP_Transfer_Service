data "google_storage_transfer_project_service_account" "default" {
  project = var.project-id
}

resource "google_storage_bucket" "s3-backup-bucket" {
  name          = "${var.aws_s3_bucket}-backup"
  storage_class = "NEARLINE"
  project       = var.project-id
  location      = "US"

  force_destroy = true
}

resource "google_storage_bucket_iam_member" "s3-backup-bucket" {
  bucket     = google_storage_bucket.s3-backup-bucket.name
  role       = "roles/storage.admin"
  member     = "serviceAccount:${data.google_storage_transfer_project_service_account.default.email}"
  depends_on = [google_storage_bucket.s3-backup-bucket]
}

resource "google_storage_transfer_job" "s3-bucket-nightly-backup" {
  description = "Nightly backup of S3 bucket"
  project     = var.project-id

  transfer_spec {
    object_conditions {
      max_time_elapsed_since_last_modification = "600s"
      exclude_prefixes = [
        "requests.gz",
      ]
    }
    transfer_options {
      delete_objects_unique_in_sink = false
    }
    aws_s3_data_source {
      bucket_name = aws_s3_bucket.examplebucket.id
      aws_access_key {
        access_key_id     = var.aws_access_key
        secret_access_key = var.aws_secret_key
      }
    }
    gcs_data_sink {
      bucket_name = google_storage_bucket.s3-backup-bucket.name
      path        = "foo/bar/"
    }
  }

  schedule {
    schedule_start_date {
      year  = 2021
      month = 11
      day   = 16
    }
    schedule_end_date {
      year  = 2022
      month = 1
      day   = 15
    }
    start_time_of_day {
      hours   = 17
      minutes = 10
      seconds = 0
      nanos   = 0
    }
  }

  depends_on = [google_storage_bucket_iam_member.s3-backup-bucket]
}

resource "aws_s3_bucket" "examplebucket" {
  bucket        = var.aws_s3_bucket
  acl           = "private"
  force_destroy = true
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.examplebucket.id
  key    = var.aws-object
  source = var.aws-object
}