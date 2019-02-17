---
date: '2019-09-14'
title: 'Æventyr'
category: 'Projects'
tags: ['Technology', 'Coding']
banner: '/projects/eventyr/banner.jpg'
icon: '/projects/eventyr/icon.png'
---


<img src="/projects/eventyr/icon.png" width="100px" align="left" style="margin-right: 10px; margin-bottom: 10px; border-radius: 20%;"/> Way back, in 2010 or so while hanging out with my friends, I randomly walked into the kitchen and burst out "Achievement unlocked!". I'm not entirely sure why that popped into my head, but it had me asking "Wait, why can't we have Achievements in real life? Oh, right, it's cause we don't have minimaps in real life". I was holding my new iPhone at the time, and this was when iPhones were a fairly new phenomenon. *"Wait, we **do** have minimaps!"*. There just wasn't any reason for why we couldn't have Achievements in real life, I thought.

I thought this would be a great project to work on - to bring the concept of *achievements* to life, as a sort of augmented reality game, and began thinking about how to structure this.

I've seen many attempts being done on this ever since, often focusing around very specific industries (e.g fitness), or niches like habit building, but none that really encompass *everything*.


Oddly enough, this is probably the only project I've worked on where coming up with the *name* and logo has been more difficult than coming up with the implementation, but I've codenamed it *Eventyr*.

>The core idea behind Eventyr is that life is only the memories you make, and the warm relations you create with other people - so lets help people do more of that!


I wanted to do this by combining people's almost infinite appetite for distractions, and addictions to often seemingly pointless games that in no way affects their lives but give a temporary feeling of achievement, I want to make **life** into a game worth playing, where the objectives are the real objectives of life: Collecting good memories, and creating warm relations. Whilst you may think you're just collecting points in an app, you're really just playing life as an augmented reality game.

By taking on the role of a child where everything is new, or as a tourist in your own city - going out and discovering places, seeing things and meeting people, you would unlock Achievements. If you make new friends along the way, that gives you higher points. The more times you complete achievements with the same people, the less amount of bonus points you get, but always more than doing it alone.

## Problems
For an app like this to be successful, it would need to have an active community, and already from the launch it would need to have a vast repository of existing Achievements people could complete. Nobody would want to download an application like this with no content (or worse: half-assed content).

Fortunately, this could be precisely the kind of app that NGO tourist organizations would like to sponsor to market their own points of interests and get their message out for tourists, for example DNT in Norway, or STF in Sweden.


The roadmap would look something like this:

1. Launch a prototype of Eventyr
2. Create a website where administrators and organizations can manage their Achievements in bulk
3. Launch in one area at the time
4. ???????
5. Profit

As you can see, there's quite a big hole in this plan: Namely, it depends *entirely* on volunteer organizations to do most of the marketing for the app, and if they're not interested, the whole thing falls together. Another one is the opposite end of the scale: What *if*, hypothetically, marketing goes extremely well and a lot of users join at once, and we need to scale immediately. I am just one person, with limited finances and time. This means that launching this app would be difficult if it doesn't go well, and difficult if it goes really well.

This is why I've decided to open-source the whole platform, and perhaps it could become one of the first open source social networking / geo-adventure apps where both the server and the client are entirely community supported.

## How would it work?
Let's say you travel to Paris, and go up the Eiffel Tower. Your phone is your minimap, and can show you all important nearby Achievements. You don't have to do anything, because as soon as you reach the Eiffel Tower, you may get a message like so:
`Achievement Unlocked: View from the Top (+85, +50 Coop. bonus) [Take photo] [Maybe later]`

We don't want to compete with other social networks, instead, it's more like a complementary app that acts as a bridge between your online social life and your real life, allowing you to collect virtual points to motivate you to collect real world experiences. All it does, is give you points for when you visit places or perform actions.

## Privacy

I'm personally a huge privacy proponent, and I can just sense the fear when something tracks your location at all times and is completely location based. This is why I've implemented this so that the user's location is *never* stored on the server. 

Instead, to find new Achievements, or unlock an Achievement, the user makes a request to the server with approximate coordinates, and receives a response - but the coordinates are never stored server-side.

Even when a user wants to find other users to cooperate with, the server never knows where other users are, but it does know what Achievements have been *suggested* to that user based on his location (and so, it knows an approximate location of a radius of 10km). 

Users to cooperate with can be suggested based on amount of matching *suggested* Achievements only, and not based on actual distance between users. It's assumed that if users have a lot of overlapping suggested Achievements (and these are suggested based on radius from user location), then they must be fairly close to one another.

No user data really needs to be kept by the server other than that, and progress on Achievements.

## Implementation

Every user has two scores: Points, and **Private** Points. Private Points are granted for unverifiable achievements, or private achievements. For example, Achievements to perform an action (lets say, Achievement: Perform 20 sit-ups) can't be verified with coordinates, and we have no way of verifying a photo even if a photo is used for verification. Therefore, this kind of Achievement only grants Private points, and they are more for fun than for competition.

Normal Points can get you on top lists, whereas Private Points cannot. However, if an Achievement that has been completed undergoes a review and published to all users, then of course everyone who has completed this Achievement will have their personal points reduced and their Points increased accordingly.

Your phone automatically keeps a local database of your Unlocked, Suggested, and Bookmarked Achievements. Whenever you have an internet connection, and this data hasn't been updated for a while, the phone sends its current coordinates to the server (and these are ***never*** stored on the server! Privacy is an important aspect built-in to this) and receives a list of nearby Achievements.

The app can then clear out the list of Suggested Achievements and update it with new Suggested Achievements. A Bookmarked Achievement is an Achievement the user has manually chosen to mark as *suggested*, whereas Suggested Achievements happen automatically as you move around in the world. This is how Achievements are unlocked as well. The app only checks the list of Suggested Achievements occasionally, running as a service in the background, and when it finds the user to be moving closer and closer to one of the Tracked Achievements, it increases the frequency to check.

When a user is within bounds of unlocking the Location Achievement, it becomes unlocked and the user is awarded points according to a simple formula. However, if the user doesn't have wifi or 3G connection, as (s)he may be traveling, the current timestamp, coordinates, Achievement, and so on is added in its local encrypted database queue. When a connection is available, all updates made to the users account are sent to the server in order, with their timestamps and signed with a HMAC based on the users secret token.

Because we never need to store coordinates of users, we can find other users who are nearby, without knowing where they are -- we just know that the two users have many Suggested Achievements in common.

### Point calculation
Points are granted based on the Category an Achievement belongs to. Every Category has a static amount of points granted to Achievements from that Category. This applies to the Type as well, which also carries some static points with it.

Finally, there are modes to indicate how complicated an Achievement is to complete.

| Mode      | Multiplier |
| :-------- | :--------: |
| Easy      |    0.5     |
| Normal    |    1.0     |
| Hard      |    1.5     |
| Nightmare |    2.0     |

An Achievement has Base Points, which is the static points granted by the Achievement. The actual points granted is then `(Achievement Base Points + Category Points + Type Points) * Mode Multiplier` and then, additionally, Cooperation Mode points if any. This is also why Personal Achievements need to be reviewed before made public, so that points are aligned fairly.

### Cooperation mode
To counter the common idea that people just stare at their phones and miss out on real life interactions, there's a feature to allow you to request *Cooperation*, or Coop. Let's say you're sitting at a café in Paris, before you're going to the Eiffel Tower. You wish to earn some extra points (reflected in real life by connecting with new people), so you opt in for Coop. Mode. You can either "Look for Group" or invite somebody else who has similar Tracked Achievement's as you.  

Whenever you unlock an Achievement/Objectives, when the points are calculated and verified officially on the server, it checks if you were linked with somebody else for that Achievement. If you were, and this person completed the same Achievement within 30 minutes of you, you will be awarded a cooperation bonus!

If you were linked but the other person has not unlocked yet, you will both be granted a coop bonus when the other person unlocks.

These points start at 85% extra, meaning that the first time you unlock an Achievement with a person, you get 85% extra points. For every time you unlock with the same person, the bonus decreases. It decreases less and less all the time, so you will always get *some* extra and never reach 0 bonus, but only the first 10-20 times will be a significant bonus. This is to encourage people to coop with *new* people and not the same friend over and over again. You can still do that, but it's not going to be that beneficial for your score.

Also, if you're cooperating with more than 1 person, you will receive the highest coop bonus you could be granted. Let's say you're cooperating with 2 others, and one of them you've never cooperated with, whilst the other you've cooperated with 5 times. You will still get the 85% bonus because you always receive the highest coop-bonus.

### Cooperating with Friends
Inspired by a quest given to an Estonian exchange student here last year, who had been given a list of Achievements to unlock before he returned home, it's also possible to create a list of Achievements and share it with other users (or on social media).

Users can then Bookmark this list, and if they complete Achievements within a certain time span of each other, they get a small cooperation bonus. If they don't, they can still see who has pinned this list and keep an eye on the progress of the user.

Cooperation bonus is awarded according to a simple algorithm that starts out at +80% extra points, and decreases logarithmically down to near 1% after 20 times, but never to 0%.

### How are Achievements created?
Users can create their own Achievements, and optionally submit them to the community. Achievements submitted to the community can be upvoted or downvoted, and after reaching a yet-to-be-decided amount of votes with a low amount of downvotes, these can be published and available for all.

If the user chooses not to submit the Achievement to the community, the Achievement remains private, and can only be completed by the user and any other users it has been shared with and bookmarked by, awarding private points.

### Model
Achievements come in many shapes and forms, the most common so far being location-based. An Achievement consists mainly of its *name*, *descriptions*, and *base points*. 

Apart from this, the most important aspects are its *Objectives*. An Achievement is really just a container for one or more objectives, and an objective may also be part of many acheivements: Objectives are the things that actually have to get done.

Right now, these are the different Achievement **types**:

* **Location**: Visit a Location to unlock
* **Discovery**: Visit multiple Locations to unlock
* **Route**: Visit multiple Locations **IN ORDER** to unlock
* **Action**: Perform an action (needs manual unlocking, and grants no **public** points)

... additions to the ones above are when a time limit is added (i.e must be completed before [date]) or recurring (i.e must be done 5 times in X days)

**Example**
> **The Highest Peaks** <br/> Find the highest mountain of each continent: <br /> * Go to Mt. Everest, <br />* Go to Mt. Aconcagua, <br /> * Go to Mt. Denali <br /> * Go to Kilimanjaro, <br /> * Go to Mt. Vinson <br />* Go to Elbrus <br /> * Go to Puncak <br />* Go to Jaya 

You may also have a different Achievement, such as
>**Basecamp** <br /> Visit the Mt Everest basecamp <br /> * Go to Mt. Everest

By completing **Basecamp**, you would have completed 1 out of 8 objectives in **The Highest Peaks** as well. This way, completing several Achievements may lead to completing one much bigger Achievement, where the Achievements shared objectives.

An Achievement is just a container for Objectives. Objectives are unlocked, and when all Objectives for an Achievement is unlocked, they grant points and the Achievement becomes unlocked.

When an Achievement is unlocked, the user can choose to take a photo. This photo has embedded geo-tagging, and this is used to verify that the location matches the approximate location of the objective unlocked. When the photo is uploaded, it causes a *Verification* of the Achievement, because we can verify the coordinates embedded in the photo one extra time, even if the request to the server was somehow tampered with. An extra way of verifying the location.


### States & Relationships
An Achievement goes through multiple states in the process. These states are in fact other objects that point to an Achievement, adding some additional information. These states are:

* **Suggested**: An Achievement in a users "quest log" or tracking list, shown on the map by default and regularly checked for progress. These are typically achievements near the users location.
* **Favorite**: A special version of Tracked with a flag that this should not be automatically removed when Tracked Achievements are updated. Pinned Achievements are created when a user *specifically* chooses to track an Achievement
* **Unlocked**: An Unlocked Achievement pointing to 0 or more Verification objects, the User who unlocked it and the Achievement

... and as for Objectives, an Objective can become *In Progress* once a user has started completing it. If it's an action that must be completed 20 times, every unlock of that Objective will be 5% towards its completeness. If the objective is to visit a location once, that one time will be 100% towards its completion and the progress will be set to complete.

And, of course, an Achievement has a *Category*, *Difficulty*, and *Type*; these are important for the points calculation.

------------------------

### Ideas for supporting future development and maintenance costs
I don't want to monetize this but it may turn out that I'll have to, to be able to sustain the costs. It's important to me that we then keep in mind that life is for everyone, and you shouldn't have to pay for this. One idea is to let companies purchase visibility on the site in a *non-intrusive* way. For example, imagine you have an Achievement for Sky-Diving. We could then pull out nearby organizations that could help you complete this Achievement, which would be more of a help to users than it would be a burden with ads.

Another idea is to release "off-shoot" apps as Enterprise-apps, e.g H&M could buy a corporate version of the app used only for employees, and this app would be branded accordingly, but only display Achievements by the organization.
