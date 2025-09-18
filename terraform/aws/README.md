# Terraform EC2 (finaltask SSH)

Konfigurasi ini membuat 2 EC2:
- **appserver**: `t3.small` (2 vCPU, 2 GiB)
- **gateway**: `t2.micro` (1 vCPU, 1 GiB)

Poin penting revisi:
- Pakai **1 SSH key bernama `finaltask`** → default `public_key_path = "~/.ssh/finaltask.pub"` dan `key_name = "finaltask-key"`.
- Security group dipakai via **`vpc_security_group_ids`** (bukan `security_groups`).
- Restart service **`ssh`** (bukan `sshd`) di `user_data`.
- SSH port diubah ke **6969**.

## Pakai cepat

1. Pastikan sudah punya key:
   ```bash
   ls ~/.ssh/finaltask.pub || ssh-keygen -t ed25519 -f ~/.ssh/finaltask -C "finaltask"
   ```

2. Buat `terraform.tfvars`:
   ```hcl
   aws_access_key  = "AKIA..."
   aws_secret_key  = "..."
   aws_region      = "ap-southeast-1" # ganti ke ap-southeast-3 (Jakarta) jika mau
   key_name        = "finaltask-key"
   public_key_path = "~/.ssh/finaltask.pub"
   ```

3. Jalankan:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. SSH (setelah apply selesai):
   ```bash
   ssh -i ~/.ssh/finaltask -p 6969 ubuntu@<appserver_public_ip>
   ssh -i ~/.ssh/finaltask -p 6969 ubuntu@<gateway_public_ip>
   ```

Simpan screenshot `init/plan/apply` dan SSH untuk laporan tugas.
