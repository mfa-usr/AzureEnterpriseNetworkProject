# Lessons Learned / Challenges Encountered

## 1. VM Size / SKU Not Available Across Regions
Azure showed VM sizes (e.g., B1/B2) as existing, but they were not actually available for my subscription in multiple regions.  
**Summary:** Azure SKU availability is not universal. A VM size can exist globally but still be blocked by region, subscription, or zone, requiring validation before deployment.

---

## 2. Misleading Azure CLI Output
The `az vm list-skus` command returned results that made it appear VM sizes were usable when they were actually restricted.  
**Summary:** Azure CLI output includes SKUs regardless of restrictions. You must inspect the `Restrictions` field to determine real availability.

---

## 3. Region and Zone Availability Mismatch
A VM size could be allowed in a region but fail in specific zones.  
**Summary:** Azure capacity is both region- and zone-dependent. Even valid regions can fail due to zone-level constraints.

---

## 4. Zonal Capacity Failures
Deployments failed with `ZonalAllocationFailed` despite valid configurations.  
**Summary:** Azure does not guarantee capacity at deployment time. Even valid SKUs can fail due to temporary capacity shortages.

---

## 5. Azure Policy Restrictions
Deployments were blocked with `RequestDisallowedByAzure`.  
**Summary:** Subscription-level policies can restrict which regions are allowed, overriding otherwise valid configurations.

---

## 6. Resource Group Region Locking
Encountered `InvalidResourceGroupLocation` when switching regions.  
**Summary:** Resource groups are permanently tied to a region and cannot be reused across regions without deletion or renaming.

---

## 7. Network as a Critical Dependency
Failures in virtual network creation caused all downstream resources to fail.  
**Summary:** Networking is a foundational dependency. If the VNet fails, all dependent infrastructure will also fail.

---

## 8. Eventual Consistency / Azure Delays
Recently deleted resources still appeared to exist or caused conflicts.  
**Summary:** Azure is eventually consistent. Resource operations may take time to propagate, requiring retries or delays.

---

## 9. Non-Idempotent Deployment Scripts
Re-running scripts caused failures such as `PropertyChangeNotAllowed`.  
**Summary:** Azure resources are not always mutable. Scripts must check for existing resources and avoid reapplying immutable properties.

---

## 10. SSH Key Immutability
Updating SSH keys on existing VMs resulted in deployment failures.  
**Summary:** Certain VM properties cannot be changed after creation, requiring deletion/recreation or conditional logic.

---

## 12. Private Networking Access Challenges
Designed the lab so only one system had a public IP. Ran into realization that that would be difficult to setup server without temporarily assigning public IP.  
**Summary:** Restricting public access improves security but requires jump hosts or Azure-native access methods for internal connectivity.

---

## 13. Cloud-init Verification
Cloud-init executed but it was unclear whether configuration steps succeeded.  
**Summary:** Cloud-init runs silently and once. Verification must be done manually via logs, services, or installed packages.