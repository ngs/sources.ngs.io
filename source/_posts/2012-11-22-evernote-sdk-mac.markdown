---
layout: post
title: "Evernote SDK for Mac: Async requests and file attachment support"
date: 2012-11-22 06:00
comments: true
categories: [Mac, Evernote, EvernoteSDK, GCD]
---

Current [HEAD](2dc7d3dae864c93952ebc008f987fb219e27883f) of [Evernote SDK for Mac OS X](https://github.com/evernote/evernote-sdk-mac) does not support async requests but the [iOS SDK](https://github.com/evernote/evernote-sdk-ios) does.

So I ported modern Objective-C code (means non-thrift) from the iOS SDK.

[ngs/evernote-sdk-mac](https://github.com/ngs/evernote-sdk-mac)

This version enables note creation very easy.

<!-- more -->

The below is an example to create new note from a PDF file as an attachment.

{% gist 4128085 evernote-sdk-sample.m %}

I have already sent a [pull-request](https://github.com/evernote/evernote-sdk-mac/pull/2) to the Evernote team. I you like this, please add comment with `+1` to the pull.