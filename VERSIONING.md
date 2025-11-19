# Peekaping Version Management

This document describes how to manage Peekaping versions for reproducible deployments.

## Current Version

The version is controlled by the `PEEKAPING_VERSION` environment variable, which defaults to `latest` but should be pinned to specific versions in production.

## Checking for New Versions

Visit the Peekaping releases page to see available versions:
```
https://github.com/0xfurai/peekaping/releases
```

## Version Pinning

### Local Development

Edit your `.env` file in `docker/peekaping/`:

```bash
# Use latest for development
PEEKAPING_VERSION=latest

# Or pin to specific version
PEEKAPING_VERSION=v1.2.3
```

### Production Deployment

The production version is controlled in the Ansible playbook vars at `ansible/playbooks/peekaping.yaml`:

```yaml
vars:
  peekaping_version: v1.2.3  # Pin to specific version
```

You can also override this during deployment:

```bash
cd ansible
ansible-playbook -i inventory-peekaping.ini playbooks/peekaping.yaml \
  -e "peekaping_version=v1.2.3"
```

## Upgrading Peekaping

### Pre-Upgrade Checklist

1. ✅ Backup your database:
   ```bash
   ssh -i peekaping-key.pem root@<server-ip>
   cp /mnt/peekaping/peekaping.db /mnt/peekaping/backup-$(date +%Y%m%d).db
   ```

2. ✅ Check the release notes for breaking changes:
   ```
   https://github.com/0xfurai/peekaping/releases
   ```

3. ✅ Test the new version locally first

### Local Testing

```bash
cd docker/peekaping

# Update version in .env
echo "PEEKAPING_VERSION=v1.2.3" >> .env

# Pull new images
docker compose pull

# Restart services
docker compose up -d

# Check logs
docker compose logs -f

# Verify health
curl http://localhost:8383/api/v1/health
```

### Production Upgrade

#### Method 1: Update Playbook (Recommended for version tracking)

1. Edit `ansible/playbooks/peekaping.yaml`:
   ```yaml
   vars:
     peekaping_version: v1.2.3  # Update to new version
   ```

2. Commit the change:
   ```bash
   git add ansible/playbooks/peekaping.yaml
   git commit -m "chore: Upgrade Peekaping to v1.2.3"
   git push
   ```

3. Re-run the deployment:
   ```bash
   make deploy-peekaping
   ```

#### Method 2: Override at Runtime (Quick updates)

```bash
cd ansible
ansible-playbook -i inventory-peekaping.ini playbooks/peekaping.yaml \
  -e "peekaping_version=v1.2.3" \
  --tags upgrade
```

#### Method 3: Manual SSH Update (Emergency only)

```bash
# SSH into server
ssh -i peekaping-key.pem root@<server-ip>

# Navigate to deployment directory
cd /opt/peekaping

# Update version in .env
sed -i 's/PEEKAPING_VERSION=.*/PEEKAPING_VERSION=v1.2.3/' .env

# Pull new images
docker compose pull

# Restart services with zero downtime
docker compose up -d

# Monitor logs
docker compose logs -f api worker producer
```

## Version Rollback

If an upgrade causes issues, you can rollback:

```bash
# SSH into server
ssh -i peekaping-key.pem root@<server-ip>

cd /opt/peekaping

# Rollback to previous version
sed -i 's/PEEKAPING_VERSION=.*/PEEKAPING_VERSION=v1.2.2/' .env

# Pull old images (if still available)
docker compose pull

# Restart
docker compose up -d
```

## Best Practices

### Production Deployments

✅ **DO**:
- Pin to specific versions (e.g., `v1.2.3`)
- Track version changes in git
- Test upgrades in development first
- Backup database before upgrades
- Read release notes for breaking changes
- Monitor logs after upgrades

❌ **DON'T**:
- Use `latest` in production
- Auto-update without testing
- Skip backups before upgrades
- Ignore deprecation warnings

### Development

✅ **DO**:
- Use `latest` to stay current
- Test new versions before production
- Document any issues found

## Monitoring Current Version

Check what version is currently running:

```bash
# Local
cd docker/peekaping
grep PEEKAPING_VERSION .env

# Production (via SSH)
ssh -i peekaping-key.pem root@<server-ip> "grep PEEKAPING_VERSION /opt/peekaping/.env"

# Check running container images
docker compose ps --format "table {{.Service}}\t{{.Image}}"
```

## Version History

Keep track of version changes in your git history:

```bash
git log --all --grep="Peekaping" --oneline
```

## Automation (Future Enhancement)

Consider adding a Makefile target for easier version management:

```makefile
upgrade-peekaping: # Upgrade Peekaping to specified version
	@read -p "Enter version (e.g., v1.2.3): " version; \
	sed -i "s/peekaping_version: .*/peekaping_version: $$version/" ansible/playbooks/peekaping.yaml && \
	echo "Updated to version $$version" && \
	echo "Run 'make deploy-peekaping' to apply the upgrade"
```

## Support

- **Releases**: https://github.com/0xfurai/peekaping/releases
- **Documentation**: https://docs.peekaping.com/
- **Docker Hub**: https://hub.docker.com/u/0xfurai
