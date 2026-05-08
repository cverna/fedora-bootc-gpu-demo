---
description: Demonstrate GitOps workflow for GPU driver upgrades using bootc
---

# GPU Driver GitOps Demo

You are running a live demo showcasing how bootc enables GitOps-style management of GPU drivers on Fedora. Walk through each step with technical narration, pausing naturally between sections to let the audience absorb the information.

## Environment

- **SSH Command**: Passed as command parameter (e.g., `ssh -i ~/.ssh/key.pem -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null user@host`)
- **Image Repository**: `ghcr.io/cverna/fedora-bootc-gpu-demo`
- **GitHub Repository**: `cverna/fedora-bootc-gpu-demo`
- **PR Number**: 1
- **Starting Driver Version**: 595.58.03
- **Target Driver Version**: 595.71.05

## Demo Steps

### Step 1: Show Current State

**Narration**: Start by explaining the current setup. We have a Fedora bootc instance running on AWS with an NVIDIA Tesla T4 GPU. The entire OS, including the NVIDIA driver, is deployed as an immutable container image. Let's verify the current state.

**Actions**:
1. SSH to the instance and run `nvidia-smi` to show the current driver version (should be 595.58.03)
2. **Running:** `sudo bootc status` - show the current booted image

**Key points to highlight**:
- Driver version 595.58.03 is baked into the image
- The image comes from `ghcr.io/cverna/fedora-bootc-gpu-demo`
- This is not a traditional package install - it's an atomic image deployment

---

### Step 2: Show the GitOps Pull Request

**Narration**: Now let's look at how we manage driver upgrades. Instead of SSH'ing into machines and running package managers, we use a GitOps workflow. A driver upgrade is simply a config file change submitted as a Pull Request.

**Actions**:
1. Run `gh pr view 1 --repo cverna/fedora-bootc-gpu-demo` to show the PR details
2. Run `gh pr diff 1 --repo cverna/fedora-bootc-gpu-demo` to show the actual change

**Key points to highlight**:
- The entire driver upgrade is a one-line change in `build-args.conf`
- `DRIVER_VERSION=595.58.03` becomes `DRIVER_VERSION=595.71.05`
- This PR can be reviewed, approved, and audited like any code change
- No manual intervention on the target machines required

---

### Step 3: Show the CI-Built Image

**Narration**: When this PR was created, GitHub Actions automatically built a new container image with the updated driver. The image is tagged with the driver version, making it easy to track and deploy specific versions.

**Actions**:
1. Narrate that CI automatically built the new image `ghcr.io/cverna/fedora-bootc-gpu-demo:43-595.71.05` when the PR was created. The tag format is `<fedora-version>-<driver-version>` (Fedora 43, driver 595.71.05)

**Key points to highlight**:
- CI built the image automatically - no manual build process
- Image is tagged `43-595.71.05` (Fedora 43, driver 595.71.05)
- The image contains the complete OS plus NVIDIA driver stack
- Ready to deploy to any number of machines

---

### Step 4: Deploy the Upgrade

**Narration**: Now for the exciting part - deploying the upgrade. With bootc, we use a single command that atomically switches to the new image and reboots. There's no package manager, no dependency resolution, no partial upgrade states. The entire OS is replaced atomically.

**Actions**:
1. **Running:** `sudo bootc switch --apply ghcr.io/cverna/fedora-bootc-gpu-demo:43-595.71.05`
2. The `--apply` flag triggers an immediate reboot
3. Wait approximately 60 seconds for the instance to come back up

**Key points to highlight**:
- `bootc switch --apply` does everything: pull, stage, and reboot
- The upgrade is atomic - it either fully succeeds or the system stays on the old image
- No half-upgraded state possible
- The previous image is retained for rollback

---

### Step 5: Verify the Upgrade

**Narration**: Let's verify the upgrade was successful. The instance should now be running the new driver version.

**Actions**:
1. SSH to the instance and run `nvidia-smi` to verify driver version is now 595.71.05

**Key points to highlight**:
- Driver upgraded from 595.58.03 to 595.71.05
- The upgrade was seamless - same GPU, same workload capability
- Total downtime was just the reboot time (~60 seconds)
- In a real cluster, you'd do rolling upgrades to maintain availability

---

### Step 6: Demonstrate Rollback

**Narration**: But what if something goes wrong with the new driver? Maybe there's a bug, or a workload incompatibility. With traditional package management, rolling back can be painful. With bootc, it's instant - the previous image is still there, ready to boot.

**Actions**:
1. **Running:** `sudo bootc rollback --apply`
2. Wait approximately 60 seconds for the instance to come back up

**Key points to highlight**:
- `bootc rollback --apply` switches back to the previous deployment
- No re-downloading required - the previous image is cached locally
- Instant recovery from problematic upgrades
- This is the safety net that makes frequent updates low-risk

---

### Step 7: Verify Rollback and Wrap Up

**Narration**: Let's confirm the rollback worked, then summarize what we've demonstrated.

**Actions**:
1. SSH to the instance and run `nvidia-smi` to verify driver version is back to 595.58.03

**Summary narration**:

We've demonstrated a complete GitOps workflow for GPU driver management:

1. **GitOps-driven changes**: Driver upgrades are config changes in Git, not manual SSH commands
2. **Automated CI/CD**: New images are built and pushed automatically on PR
3. **Atomic upgrades**: `bootc switch --apply` replaces the entire OS atomically
4. **Instant rollback**: `bootc rollback --apply` recovers from issues in seconds

**Contrast with GPU Operator approach**:
- GPU Operator: Runtime driver compilation, kernel module loading, potential version mismatches
- bootc: Pre-built, tested images with driver baked in, guaranteed consistency

**Benefits for fleet management**:
- Every machine runs the exact same image
- No configuration drift
- Auditable change history in Git
- Test upgrades in staging before production rollout
- Instant rollback if issues are detected

This is the future of infrastructure management - treating your entire OS stack, including GPU drivers, as immutable, version-controlled artifacts.
