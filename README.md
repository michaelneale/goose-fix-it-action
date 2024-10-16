# goose fix it

A github action to run https://github.com/block-open-source/goose to take on tasks in the background for you using AI.
You can label an issue with `goose` and it will open a pull request to fix it. 
You can say `help me @goose-ci - can you clean up the mess` in a pull request comment on any pull request, and goose will try to assist and fix up your PR.

> [!WARNING]
> An alpha version of goose for github actions!

## Usage

Use goose to fix a github issue:
![Screenshot 2024-09-23 at 6 27 57 PM](https://github.com/user-attachments/assets/b41d39d3-c6da-4f64-8673-96af75348036)

goose attempts to fix and if things go well, it will open a PR with the fix for the issue (if it can't, no PR will result, so it has to be confident it has fixed the issue or built the feaure):
![Screenshot 2024-09-23 at 6 28 08 PM](https://github.com/user-attachments/assets/e7204eed-e379-4507-8cf4-77362a1ad243)

goose will help out in the middle of a PR review: 

![image](https://github.com/user-attachments/assets/d615d226-beee-43f5-b894-9a6255dac0e3)

goose runs as an action in your github workflow, so you can add it to your existing CI workflow files and use the same build environment (so it can check its work as it goes by testing your code and its changes - it isn't just editing or generating code).

## Configuration

In your .github workflows, make a new workflow for goose:

```yaml
name: Goose Do It

# trigger when there is a labelled issue, or a comment 
on:
  issues:
    types:
      - labeled
  issue_comment:
    types:
      - created      

jobs:
  ask-goose:
    # this will run when an issue is labelled 'goose' or if a comment in a pull request asks for help from @goose-ai
    if: github.event.label.name == 'goose' or ${{ github.event.issue.pull_request && contains(github.event.comment.body, '@goose-ai') }}
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repo
        uses: actions/checkout@v2
        with:
          fetch-depth: 0

      ## Install whatever you need here as per your CI setup for your project

      - name: Run Goose Action
        uses: michaelneale/goose-fix-it-action@main
        with:
          task_request: |
            ${{ github.event.issue.title }}
            ${{ github.event.issue.body }}
            [Link to issue](${{ github.event.issue.html_url }})
          validation: "check the vite web app installs"          
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
          GH_TOKEN: ${{ github.token }} # can change this to secrets.PAT if you want to trigger workflows
```

This example will both open pull requests IF it can come up with a validated change. 
It will also trigger if you mention `@goose-ai` in a pull request (could be one someone else opened, or goose opened), in that case, it will try to address the feedback and push the change back to the pull request.

The `validation` is what goose will use to check its changes - it can be any directions on how to verify/test (eg what commands to run etc, in natural language, it will work it out). The `task_request` is instruction on what to do.

See [Github Issue Fixer Workflow](.github/workflows/goose-example-workflow.yml) example as a template.

To ensure this works: 
* create a goose label in your github project
* ensure github actions can open PRs and have read/write access (see image below)
* setup a github action secret for OPENAI_API_KEY or ANTHROPIC_API_KEY as appropriate (anything supported by goose)


Github permissions for the action are required to be set in your repo:  
![image](https://github.com/user-attachments/assets/a9d0e307-2d93-4aa5-bb93-a933fb1a3231)


## Advanced usage and customising. 

There are many other ways to use the goose action in your workflows, it doesn't have to be triggered from a github issue (could be any issue tracker, or any event, or even on demand - via an input for example). The key thing is the workflow is setup to build your app from source (you can use your existing ci workflow in github actions).

If you want to customise how it opens a PR, you can set `create_pr: false`, and then use https://github.com/peter-evans/create-pull-request or similar in your own workflow to open PRs or take other actions however you like.
You can also stop it from udpating a PR with `update_pr: false`. 

Note due to github limitations, PRs opened by the default GITHUB_TOKEN won't trigger workflows (but you can use a personal access token and set it to GH_TOKEN if you do want it to do that, or have it trigger downstream workflows).

The goose action: 
```yaml
      - name: Run Goose Action
        uses: michaelneale/goose-fix-it-action@main
        with:
          task_request: |
            any description of the task (eg issue input, comments etc)
          validation: "how to verify the change works"
          create_pr: 'true'
          update_pr: 'true'
        env:
          ANTHROPIC_API_KEY: ${{ secrets.KEY }} # or open ai, or anything really
          GH_TOKEN: ${{ github.token }} # or a personal access token 
```
The action knows if it is triggered by a PR comment or a new issue, and will act accordingly. 

Check out https://github.com/block-open-source/goose for more on goose.

> [!WARNING]  
> Always review goose changes that it proposes.

