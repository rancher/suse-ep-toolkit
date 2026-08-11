# Contributing Guideline

Thanks for contributing to this project!

Please follow the [Code of Conduct](https://github.com/rancher/harvester-cloud/blob/main/CODE_OF_CONDUCT.md):

## Important: Issue required before any Pull Request

Before opening a Pull Request, you MUST open an issue first.

The issue is required to:
- describe the problem or feature request
- allow discussion before implementation
- avoid uncoordinated or duplicated work

Pull Requests without a related issue may be closed.

## Contributions

Contributions are not limited to code. Issues, feedback, and feature suggestions are welcome.

## Pull Request Guidelines

Each PR should address a single issue.

Keep PRs small and focused to make review easier.

For large changes, multiple logical commits are allowed.

## Commit Requirements (DCO / Signed-off-by)

All commits must include a Signed-off-by trailer.

Use:

git commit -s -m "meaningful commit message"

All commits are verified by CI. Missing Signed-off-by will fail checks.

This ensures compliance with the Developer Certificate of Origin (DCO).

## Workflow

1. Fork the repository
2. Open an issue describing your change
3. Clone your fork
   ```sh
   git clone git@github.com:rancher/harvester-cloud.git
   ```

4. Add your fork remote
   ```sh
   git remote add mycopy <your-fork-url>
   ```

5. Create a feature branch
   ```sh
   git checkout -b feature-branch-name
   ```

6. Make your changes

7. Format Terraform code
   ```sh
   terraform fmt -recursive .
   ```

8. (Optional) Update docs
   ```sh
   terraform-docs markdown .
   ```

9. Commit changes
   ```sh
   git commit -s -m "meaningful message"
   ```

10. Push to your fork
   ```sh
   git push mycopy feature-branch-name
   ```

11. Open a Pull Request linked to the issue

## Review & Merge Policy

- PRs require at least one approval
- Prefer "Rebase and merge" for single-commit PRs
- Use "Create merge commit" for multi-commit PRs
- Squash commits if needed before merge
