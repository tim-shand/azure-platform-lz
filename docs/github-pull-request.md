# GitHub: Create a Pull Request

1. Add changes in current working directory to the local Git repository and commit with descriptive message. 

```bash
git add . && git commit -m "fix: Corrected the naming of a resource."
```

2. Push the changes in the current branch. 

```bash
git push origin feature-branch-name
```

3. Submit a pull request for merge with "main" branch. 

```bash
gh pr create --base main --title "Removal of unnecessary Terraform output" --body "Removed the 'out_gh_env' output from the Terraform module outputs.tf file."
```
