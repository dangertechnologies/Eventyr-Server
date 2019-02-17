# Eventyr / Iriri


## Idea
Iriri means Experience in Haitian Creole. Eventyr means adventure in Norwegian. And that's exactly the idea behind this: That life is only the memories you make, and the warm relations you create with other people.

In an attempt at combining people's almost infinite appetite for distractions, and addictions to often seemingly pointless games that in no way affects their lives but give a temporary feeling of achievement, I want to make **life** into a game worth playing, where the objectives are the real objectives of life: Collecting good memories, and creating warm relations. Whilst you may think you're just collecting points in an app, you're really just playing life as an augmented reality game.

## How would it work?
Basically, it's "Achievements" brought to real life. Let's say you travel to Paris, and go up the Eiffel Tower. Your phone is your minimap, and can show you all important nearby Achievements. You don't have to do anything, because as soon as you reach the Eiffel Tower, you may get a message like so:
`Achievement Unlocked: View from the Top [+85 (+50 Coop. bonus)] [Take photo] [Maybe later]`

We don't want to compete with other social networks, instead, it's more like a complementary app that acts as a bridge between your online social life and your real life, allowing you to collect virtual points to motivate you to collect real world experiences. All it does, is give you points for when you visit places or perform actions.

### How does the score system work?

Every user has two scores: Personal Points, and Global Points. Personal Points are granted for unverifiable achievements, or personal achievements. For example, Achievements to perform an action (lets say, Achievement: Perform 20 sit-ups) can't be verified with coordinates, and we have no way of verifying a photo even if a photo is used for verification. Therefore, this kind of Achievement only grants Personal points, and they are more for fun than for competition.

Global Points can get you on top lists, whereas Personal Points cannot. However, if an Achievement that has been completed undergoes a review and is made Global, then of course everyone who has completed this Achievement will have their personal points reduced and their Global Points increased accordingly.

---------------------------------

![Screenshot from Home page](../master/doc/home.png?raw=true)
![Screenshot from Achievement page](../master/doc/achievement.png?raw=true)

**Note**: These are subject to change. :)

---------------------------------

## But, more technically, how is this implemented?
Your phone automatically keeps a local database of your Unlocked, Tracked, and Pinned Achievements. Whenever you have an internet connection, and this data hasn't been updated for a while, the phone sends its current coordinates to the server (and these are ***never*** stored on the server! Privacy is an important aspect built-in to this) and receives a list of nearby Achievements.

The app can then clear out the list of Tracked Achievements and update it with new Tracked Achievements. A Pinned Achievement is an Achievement the user has manually chosen to track, whereas Tracked Achievements happen automatically as you move around in the world. This is how Achievements are unlocked as well. The app only checks the list of Tracked Achievements occasionally, running as a service in the background, and when it finds the user to be moving closer and closer to one of the Tracked Achievements, it increases the frequency to check.

When a user is within bounds of unlocking the Location Achievement, it becomes unlocked and the user is awarded points according to a simple formula. However, if the user doesn't have wifi or 3G connection, as (s)he may be traveling, the current timestamp, coordinates, Achievement, and so on is added in its local (and ENCRYPTED to avoid tampering) database queue. When a connection is available, all updates made to the users account are sent to the server in order, with their timestamps and signed with a HMAC based on the users secret token.

Because we never need to store coordinates of users, we can find other users who are nearby, without knowing where they are -- we just know that the two users have many Tracked Achievements in common.

### Point calculation
Points are granted based on the Category an Achievement belongs to. Every Category has a static amount of points granted to Achievements from that Category. This applies to the Type as well, which also carries some static points with it.

Finally, there are modes to indicate how complicated an Achievement is to complete.

| Mode   | Multiplier|
|:-------|:---------:|
| Easy   | 0.5       |
| Normal | 1.0       |
| Hard   | 1.5       |
| Nightmare| 2.0     |

An Achievement has Base Points, which is the static points granted by the Achievement. The actual points granted is then `(Achievement Base Points + Category Points + Type Points) * Mode Multiplier` and then, additionally, Cooperation Mode points if any. This is also why Personal Achievements need to be reviewed before made public, so that points are aligned fairly.

## What's Cooperation mode?
To counter the common idea that people just stare at their phones and miss out on real life interactions, there's a feature to allow you to request *Cooperation*, or Coop. Let's say you're sitting at a café in Paris, before you're going to the Eiffel Tower. You wish to earn some extra points (reflected in real life by connecting with new people), so you opt in for Coop. Mode. You can either "Look for Group" or invite somebody else who has similar Tracked Achievement's as you.  

Whenever you unlock an Achievement/Objectives, when the points are calculated and verified officially on the server, it checks if you were linked with somebody else for that Achievement. If you were, and this person completed the same Achievement within 30 minutes of you, you will be awarded a cooperation bonus!

If you were linked but the other person has not unlocked yet, you will both be granted a coop bonus when the other person unlocks.

These points start at 85% extra, meaning that the first time you unlock an Achievement with a person, you get 85% extra points. For every time you unlock with the same person, the bonus decreases. It decreases less and less all the time, so you will always get *some* extra and never reach 0 bonus, but only the first 10-20 times will be a significant bonus. This is to encourage people to coop with *new* people and not the same friend over and over again. You can still do that, but it's not going to be that beneficial for your score.

Also, if you're cooperating with more than 1 person, you will receive the highest coop bonus you could be granted. Let's say you're cooperating with 2 others, and one of them you've never cooperated with, whilst the other you've cooperated with 5 times. You will still get the 85% bonus because you always receive the highest coop-bonus.

### Cooperating with Friends
Inspired by the quest given to an Estonian exchange student here last year, who had been given a list of Achievements to unlock before he returned home, it's also possible to create a list of Achievements and share it with other users (or on social media).

Users can then Pin this list (forced Tracking), and if they complete Achievements within a certain time span of each other, they get a small cooperation bonus. If they don't, they can still see who has pinned this list and keep an eye on the progress of the user.

------------------------------------------

## Digging deeper...

Alright, I'll try to get a bit more in-depth here ... I may have missed a lot though :(

### How do users sign up?
Users can sign-in with any social network account. As of now, it supports Tumblr, Reddit, Facebook, Twitter, and Google+. It's also possible to sign up without a social network account, using E-mail and Password.

### How are Achievements created?
Users can create their own Achievements (and if they wish, they can hit "Request Review" to make it a global one!), and they can Share their Personal Achievements with others as well. Until it has undergone a review, it will remain Personal.

Right now, I have just made a script that crawls the web and collects interesting places and their coordinates and turns it into Objectives and Achievements (but the descriptions of these will need to be updated :/).

### Achievements & their attributes
Achievements come in many shapes and forms, the most common so far being location-based. An Achievement consists mainly of its *name*, *descriptions*, and *base points*. Apart from this, the most important aspects are its *Objectives*. Objectives are the things that actually have to get done, and an Achievement can consist of 1 or many Objectives that must be completed.

An Achievement can expire and not be possible to complete after a certain date.

#### So, what kind of Achievements are there? Only Location?
Nope! There's a few different ones already from the start, and we could continue adding more later on. Right now, these are the different Achievement **types**:

* **Location**: Visit a Location to unlock
* **Discovery**: Visit multiple Locations to unlock
* **Route**: Visit multiple Locations IN ORDER to unlock
* **Action**: Perform an action (needs manual unlocking, and grants no **public** points)

... additions to the ones above are when a time limit is added (i.e must be completed before [date]) or recurring (i.e must be done 5 times in X days)

Furthermore, an Achievement is just a container for Objectives. Objectives are unlocked, and when all Objectives for an Achievement is unlocked, they grant points and the Achievement becomes unlocked.

When an Achievement is unlocked, the user can choose to take a photo. This photo has *forced* geo-tagging, because this is what we need. When the photo is uploaded, it causes a *Verification* of the Achievement, because we can verify the coordinates embedded in the photo one extra time, even if the request to the server was somehow tampered with. An extra way of verifying the location.

If the user has opted in for social media sharing, we can post the "Achievement Unlocked: [name] [points]" along with the photo to each of his/her social media accounts.

Additionally, Achievements belong to a **Category**, and have a **Mode Multiplier**.

##### States & Relationships
An Achievement goes through multiple states in the process. These states are in fact other objects that point to an Achievement, adding some additional information. These states are:

* **Dependency**: A link between an Achievement and other Achievements that must be completed first.
* **Tracked**: An Achievement in a users "quest log" or tracking list, shown on the map by default and regularly checked for progress
* **Pinned**: A special version of Tracked with a flag that this should not be automatically removed when Tracked Achievements are updated. Pinned Achievements are created when a user *specifically* chooses to track an Achievement
* **Unlocked**: An Unlocked Achievement pointing to 0 or more Verification objects, the User who unlocked it and the Achievement

... and as for Objectives, an Objective can become *In Progress* once a user has started completing it. If it's an action that must be completed 20 times, every unlock of that Objective will be 5% towards its completeness. If the objective is to visit a location once, that one time will be 100% towards its completion and the progress will be set to complete.

And, of course, an Achievement has a *Category*, *Mode*, *Type*; these are important for the points. To represent the Achievement, it has an *Icon*, and a link to the user who created it.

**Digging Deeper**: If you want to know more about how Achievements are connected to other objects, check the [generated diagram](./doc/models_complete.svg)

------------------------

## Are you planning on monetizing this, and if so, how?
I don't want to monetize this but it may turn out that we'll have to, to be able to sustain the costs. It's important to me that we then keep in mind that life is for everyone, and you shouldn't have to pay for this. Maybe let an ad-free version of the app cost $1 or something.

Another idea is to let companies purchase visibility on the site in a *non-intrusive* way. For example, imagine you have an Achievement for Sky-Diving. We could then pull out nearby organizations that could help you complete this Achievement, which would be more of a help to users than it would be a burden with ads.

## So, what's done and what needs to be done?
Basically the whole back-end is done, and the API for the app to communicate with is done as well. The website needs some finishing touches, but is also nearing completion.

Icons for Achievements and actions, lists and a logo are also things needed. Preferably a better website design as well - I'm a coder, not a designer, unfortunately :(

If you would like to help out with Windows Phone, iOS, or Android development -- or graphics! -- don't hesitate to contact me :)

### Missing
* Allow user to upload image for verification
* Fetch users with similar tracking
* Fetch users currently tracking a specific achievement (for Coop)
* Improve database queries and replace shitty loops