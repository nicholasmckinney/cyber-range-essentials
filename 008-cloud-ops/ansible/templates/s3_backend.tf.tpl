terraform {
  backend "s3" {
    bucket = "{{ terraform_bucket }}"
    key    = "{{ terraform_state_key }}"
    region = "{{ region }}"
  }
}
