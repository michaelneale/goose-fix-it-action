# goose fix it

> [!WARNING]
> An alpha/very early version of goose for github actions!


A github action to run [goose-ai](https://github.com/square/goose) to take on tasks in the background for you using AI.

> [!NOTE]
> Some have suggested this be pronounced "goosey".

## Usage

Use goose to fix a github issue:
![Screenshot 2024-09-23 at 6 27 57 PM](https://github.com/user-attachments/assets/b41d39d3-c6da-4f64-8673-96af75348036)

goose attempts to fix and if things go well, it will open a PR with the fix for the issue (if it can't, no PR will result, so it has to be confident it has fixed the issue or built the feaure):
![Screenshot 2024-09-23 at 6 28 08 PM](https://github.com/user-attachments/assets/e7204eed-e379-4507-8cf4-77362a1ad243)

goose runs as an action in your github workflow, so you can add it to your existing CI workflow files and use the same build environment (so it can check its work as it goes by testing your code and its changes - it isn't just editing or generating code).

## Configuration

In your github workflow, you add the goose action: 

```yaml
      - name: Run Goose Action
        uses: michaelneale/goose-fix-it-action@main
        with:
          task_request: |
            ${{ github.event.issue.title }}
            
            ${{ github.event.issue.body }}
            
            [Link to issue](${{ github.event.issue.html_url }})
          validation: "test instructions here"
          create_pr: 'true'
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
```


The `validation` is what goose will use to check its changes - it can be any directions on how to verify/test (eg what commands to run etc, in natural language, it will work it out). The `task_request` is instruction on what to do.

In this case it is using the github issue that triggered the workflow to direct goose. You can use this workflow here as a basis if you want it to work that way: 
[Github Issue Fixer Workflow](.github/workflows/goose-example-workflow.yml).

To ensure this works: 
* create a goose label in your github project
* ensure github actions can open PRs and have read/write access (see image below)
* setup a github action secret for OPENAI_API_KEY or ANTHROPIC_API_KEY as appropriate (anything supported by goose)

Github permissions for the action are required to be set in your repo:  
![image](https://github.com/user-attachments/assets/a9d0e307-2d93-4aa5-bb93-a933fb1a3231)


## Advanced usage and customising. 

There are many other ways to use the goose action in your workflows, it doesn't have to be triggered from a github issue (could be any issue tracker, or any event, or even on demand - via an input for example). The key thing is the workflow is setup to build your app from source (you can use your existing ci workflow in github actions).

If you want to customise how it opens a PR, you can set `create_pr: false`, and then use https://github.com/peter-evans/create-pull-request or similar in your own workflow to open PRs or take other actions however you like.

Note due to github limitations, PRs opened by the default GITHUB_TOKEN won't trigger workflows (but you can use a personal access token if you do want it to do that, or have it trigger downstream workflows). 

Check out https://github.com/block-open-source/goose for more on goose.


> [!WARNING]  
> Always review goose changes that it proposes.

