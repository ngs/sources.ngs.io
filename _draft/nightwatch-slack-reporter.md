# Receive Nightwatch.js End to End test result with Slack

## TL;DR

I've published a Nightwatch.js reporter that notifies test results on Slack Channels. Try it!

https://

## Motivation 

As I mentioned in last entry in this blog, we started using Nightwatch.js for End to End testing of our web and desktop client.

We run the tests on CircleCI that helps us running tests anywhere.

However CircleCI's built in chat notifications are not enough information to figure out what caused fails, so we need to open build logs on the web browser (or CI2Go) when we see test failure notifications.

To shortcut these steps in our daily testing flow, I've published a custom reporter that notifies test results on Slack Channel.

## Installing

npm install --save-dev 

## Configurations

## More customization 


