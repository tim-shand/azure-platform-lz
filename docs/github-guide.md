# GitHub Guide

## Create a Pull Request

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

## Update Branch from Main

1. Switch to your feature branch:

```bash
git checkout dev
```

2. Fetch the latest changes from the remote repository to ensure your local master is up-to-date:

```bash
git fetch origin
```

3. Merge the remote master branch into your current branch:

```bash
git merge origin/master
```

4. Resolve any merge conflicts that may arise. After resolving, commit the changes if Git doesn't do it automatically.
Push your updated branch to the remote repository:

```bash
git push origin your-feature-branch
```
