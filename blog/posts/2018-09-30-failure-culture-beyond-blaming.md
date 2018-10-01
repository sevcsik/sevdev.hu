----------------------------------------
title: "Failure culture: Beyond blaming"
----------------------------------------

It's inevitable that people make mistakes. Often, the impact of these mistakes are high - sometimes it breaks other team's code, introduces regressions which can lurk around for a long time. On large projects, especially where a good chunk of legacy is in play, mistakes happen more often and are way more harder to find.

You can also make a mistake by having the wrong idea; you stick to it, pour more and more of your (and others') energy into it, and it turns out not being a solution to your problem.

At the end of the day, you **will** fail as everyone else, and you have to be able to make that failure useful, so it can contribute to your next success.

<!-- TEASER -->

# The Blame Game

Probably you heard these a plenty times:

  - "I've told this a thousand times but people are **still doing it**!"
  - "Great, another three months of work thrown out the window"
  - and my personal favourite: "Who will take the responsibility for this?"

If the *lack of accountability* and *blame game* are recurring themes on your retrospectives, your organisation might have a problem with handling failure. These two issues may seem contradictory, but in fact they go hand in hand and amplify each other.

If people see that mistakes are left unhandled, they will call each other out on it - probably not the most polite way, out of frustration, doing a lot of collateral damage in the process. When people expect to be blamed and pilloried for making mistakes, they are more likely to avoid admitting their mistakes and thus learn from them.

Culture won't change by talking about it. What you can do is start acting on it and believe that others will follow.

# How [Agile Development][manifesto] Helps Dealing with Failure

Agile development methods focus on people, adaptability and of course quality. Learning from failures are not just an option, but a core part of the methodology. Every mistake is an opportunity to adapt, and they have to be taken care of in a way to get the most value out of them. If they are handled properly, failure can be just as valuable as success.

## Trust

We trust people to deliver. It doesn't mean we're not prepared for someone failing but if it happens, we trust that we will learn from the failure and adapt.

## Transparency

Transparency is a core value of agile development. Responsibilities are clearly defined, progress is clearly communicated and each and every one's work must be visible for team members and external stakeholders. In a truly agile workflow, "getting away" with a mistake cannot be possible.

## Continuous Feedback

Breaking down the work to bite-size chunks and delivering working software as frequently as possible limits the impact of a failure and allows us to adapt quickly.

## Retrospective

Regularly reflecting on how the team operates gives us the opportunity to learn from our mistakes and adjust our processes to make sure that the mistake won't happen again.

## [Minimum Viable Value][mvv]

When trying out new ideas, it's essential that we concentrate on delivering the MVV that's enough to test the validity of the idea. In case of the idea turns out to be invalid or not feasible, we can limit the amount of sunk costs by getting that information as soon as possible.

# How to Handle Failure in a Constructive Way

## If You are the One to Blame

You made a mistake. It might be a pretty banal one. Somehow it all the way through, wasting others' time / went to production / disrupted the work of another team. Shit happens.

Whether you discovered your own mistake or someone else did, **take ownership**. Open a bug, talk to your boss, and fix it ASAP. **Be honest** about how did the mistake happen. Most importantly, identify what can you do different in the future to avoid making the same mistake again. It's not just for you: others can learn from your experience as well.

Be proactive and find ways to catch mistakes like this in the future. Maybe a new tool could help to catch this earlier or the [working agreement][working-agreement] should be extended. Be sure to bring up the issue on your next retrospective.

What you should not do is to shift blame to others. Yes, you made the mistake, but it passed the review and testing! *They also made a mistake!*. Perhaps they did, but it doesn't make your mistake smaller. Leave the dealing with their part of the responsibility to them, and concentrate on your own.

On the other hand, if you see someone taking responsibility and you also feel responsible, join the discussion and elaborate how you could do your part better.

It's worth it. Admitting your mistakes not just help you and your organisation to learn, but it also helps you to keep your integrity and build your character. No wonder why [great][linus] [people][null-ref] [are][ctrl-alt-del] [doing][double-slash] [it][cambridge-analytica].

## If You are the One Who Blames

You found a nasty bug. Turns out to be a rookie mistake, or even worse, blatant ignorance. You can't imagine making such mistake because you're one of the [90% who's above the average][illusory-superiority]. Your day is ruined because you spent time cleaning up someone's mess instead of doing something useful.

First of all, give yourself time to calm down. Then try to reach the person privately: give them the chance to take ownership of their mistake and manage it according to the previous section. If it doesn't work, talk to their manager or a senior member of their team.

Don't start with gathering evidence and writing an essay about what went wrong, you're not going on a trial. You're not just wasting your own time with it, but creating an atmosphere where the other will feel like they need to defend themselves instead of taking ownership of their mistake.

Of course if you have some **constructive** thoughts, it's ok to publish them on a broader forum, but do it with diligence and only after you tried talking to the "offender" privately first. And **never, ever** do it in a way that the affected person is not involved and cannot participate in the discussion.


# References
- [How to Stop the Blame Game][hbr] on Harvard Business Review
- [What Does It Mean to Create a 'Culture of Failure'?][rework] on Rework Magazine

[rework]: https://www.cornerstoneondemand.com/rework/what-does-it-mean-create-culture-failure
[hbr]: https://hbr.org/2010/05/how-to-stop-the-blame-game
[working-agreement]: https://shift.newco.co/2017/07/23/team-working-agreements-the-why-what-and-how
[linus]: https://www.theregister.co.uk/2018/09/17/linus_torvalds_linux_apology_break
[null-ref]: https://en.wikipedia.org/wiki/Tony_Hoare#Apologies_and_retractions
[ctrl-alt-del]: https://www.theverge.com/2013/9/26/4772680/bill-gates-admits-ctrl-alt-del-was-a-mistake
[double-slash]: https://www.zdnet.com/article/double-slash-in-web-addresses-a-bit-of-a-mistake
[cambridge-analytica]: https://www.theguardian.com/technology/2018/mar/21/mark-zuckerberg-response-facebook-cambridge-analytica
[illusory-superiority]: https://en.wikipedia.org/wiki/Illusory_superiority
[manifesto]: http://agilemanifesto.org/principles.html
[mvv]: https://www.mikecrunch.com/mvv-is-the-new-mvp/?utm_campaign=Submission&utm_medium=Community&utm_source=GrowthHackers.com
