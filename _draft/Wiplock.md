# Wiplock - Protect main branch from in-progress branches

## TL;DR

I released Wiplock that protects main branch from pull requests that contains WIP in the title or incompleted tasks. Try it out!

## Motivation

In　out　daily　development　flow,　we　send　WIP　pull　requests　on　GitHub　before　implementation　was done.

Sometimes we mistakenly merge these pull requests before the tasks are completed or forget removing `WIP` in the title that may confuse collaborators.

To prevent these kind of mis-operations, I've built an tiny web application called Wiplock.

## How it works

1. Login with GitHub
2. Find repository
3. Turn the switch on
4. Test that works
5. Turn on protect branch

## Launch your own Wiplock

If you don't want give permission managed by someone else, you can launch your own Wiplock on Heroku or Docker hosts.

### Pre-requirements 

You need to create your OAuth Application on GitHub.

### Heroku

Just hit the Heroku Button on README of the repository.

### Docker

Redis server is required to launch on your host.

If you don't have it yet, the Official Docker image will help you bootstraping.

---

Pull Wiplock Docker image.


And run Wiplock by passing REDIS_URL with running container name.

## Milestones

- Support locking pull requests labeled `in progress`
- Support customizing locking conditions using `.wiplock.yml` on the repository root

I wish this could help your workflow safe, happy locking!


