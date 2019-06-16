UPDATE Policies SET
TechPrereq = (
	SELECT PolicyBranchTechPrereq.TechType
	FROM PolicyBranchTechPrereq
	WHERE Policies.PolicyBranchType = PolicyBranchTechPrereq.BranchType
)
WHERE EXISTS(
	SELECT * FROM PolicyBranchTechPrereq WHERE Policies.PolicyBranchType = PolicyBranchTechPrereq.BranchType
);

UPDATE Policies SET
TechPrereq = (
	SELECT PolicyBranchTechPrereq.TechType
	FROM PolicyBranchTechPrereq
	WHERE Policies.Type = PolicyBranchTechPrereq.EntryPolicy
)
WHERE EXISTS(
	SELECT * FROM PolicyBranchTechPrereq WHERE Policies.Type = PolicyBranchTechPrereq.EntryPolicy
);

Update PolicyBranchTypes SET EraPrereq=NULL WHERE Type NOT IN ('POLICY_BRANCH_FREEDOM', 'POLICY_BRANCH_ORDER', 'POLICY_BRANCH_AUTOCRACY');
