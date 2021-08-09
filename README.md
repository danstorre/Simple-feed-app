# Simple feed app
A simple app presenting a popular whisper feed and its Whisper's most popular thread.

## Specs

Story - Customer request to see the most Popular Reply thread from the Popular feed.

Given a customer has connectivity
When the user request to see the Popular Feed
Then the app should display a list of the most popular whispers

Given a customer has connectivity
When the user request for details of a Popular Whisper
Then the app should display its most Popular Reply Thread

## Use cases

Use Cases

Load Popular Whispers Feed Use Case

Data:
URL

Primary course:

1. Execute "Load Popular Whispers Feed ” command with above data.
2. System Downloads Data From URL.
3. System Validates Data from the URL
4. System creates a list of whispers from the given data.
5. System Delivers the Popular Whispers Feed.

No connectivity - error course:
1. System delivers error

Invalid data - error course:
1. System Delivers error.

Load Most Popular Reply Thread from a Whisper Use Case

Data:
URL
Whisper

Primary course:

1. Execute "Load Most Popular Reply Thread from a Whisper” command with above data and Whisper data.
2. System Downloads Data From URL with the ID from Whisper.
3. System Validates Data from the URL.
4. System Creates the array of Reply Threads from the given whisper.
5. System executes same command recursively from all replies related to the root whisper and its descendants.
6. System Determines the most Popular Reply Thread given the graph of reply whisper.
7. System Delivers the most Popular Reply Thread.

Operation Error - error course:
1. System delivers error

No connectivity - error course:
1. System delivers error

Invalid data - error course:
1. System Delivers error.




## Initial Proposed Architecture
![MediaLab](https://user-images.githubusercontent.com/12664335/125976255-bb2fe7e0-dcd0-43b0-b0f8-4aa5127ce968.png)
