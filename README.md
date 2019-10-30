# REST-API-Automation

Thanks for taking the time to check out my project. This project contains automated tests written in Tavern for the Avero test API (Original repo here: https://github.com/AveroLLC/sdet-exercise). I went with Tavern because it's a tool I've used before. One advantage is that it doesn't have a GUI, allowing for more flexibility in the way tests are run. The downside is Tavern is light on some features, including API monitoring.

To eliminate any environment-related issues, I dockerized the test script, which will execute automatically when the container is running. The setup is outlined below. 

Prerequisites:
* Avero test API running locally
* Docker installed

Clone and cd to this repo, then run the following:

`docker build -t test .`

`docker run -it --network host test`

Expected results: 24 failed, 26 passed


## Observations/Reasonings:

### Overall
* There's a lack of error-handling and the HTTP status codes don't always make sense (see below)
* In my testing I noticed that every time you request data from both all endpoints via the browser, the first response returns a 200 HTTP status code and the second (usually but not always) returns a 304. This is a very interesting case to handle because many REST API testing tools wouldn't have picked this up. I verified that running the tests multiple times from the automation has no effect on the pass rate of the affected tests cases.

### Businesses endpoint
* A lot of my negative test cases will fail because a 200 HTTP status code is thrown instead of a 4xx status code. In this exercise I made the assumption as to which 400-level client error should be displayed and wrote it into the test cases. In a real-world situation I would discuss with the development team and we would come up with a solution together.
* How do we handle the case where we are requesting multiple businessIds, and one is valid while the other isn't? Currently, the invalid one is ignored and the data for the valid businessId is returned. I don't necessarily disagree with this behavior, however the user may not realize that the other businessId is invalid. Same goes for a list of businessIds and one is blank (ex: 1111,,7777). In my tests I failed these because the expected behavior wasn't clear. I would discuss these scenarios with the development team. I also added test cases distinguishing a difference between a space and no space between the delimiter. In my experience building APIs, these can be handled differently. Another situation is where the user enters the same businessId twice. I did pass this one only because the response does technically return the correct data. However, I would still discuss this with the team.
* Since the data refers to individual businesses, I dedicated a test to making sure that each exists. In the unlikely event that a business was removed from the database, or wherever the data exists, the test would be able to pinpoint that something is wrong.

### Summary-sales endpoint
* For the summary-sales endpoint, I need some clarification on how much data is supposed to be returned when sending a specific businessId in the request without a businessDay specified. Right now it returns the current business day. This seems like it would be correct but I don't want to assume and would check in with the development team.
* Fort same endpoint, I see that all of the businessDays are showing an error when no date is specified (ex: "No data found. The business was closed on the given requested day"). I understand that since it's the current day, which is not finished, the data may not be available. However, I think the messaging in this situation is misleading because the restaurant may not actually be closed. I would discuss this with the dev team. The HTTP status code would also be discussed because it's 200.
* Entering an invalid date format (ex: dd-MM-yyyy) throws a HTTP 500 error with the message "Invalid date: <dateEntered>". The error code indicated that this was an unexpected condition and this is a bug. The response should be 400 because the user input was incorrect. The error message should indicate what the correct date format is.

## Possible cases that aren't automated:
- Validate some of the data returned (specifically the business information).
- Is it possible to have negative decimal amounts?
- Are the currency codes calculated or are they static? 
- Sales where the time is close to being at the end/beginning of the day. This would test the time zone logic for businesses.
- There are a lot of min/max amounts mentioned in the API documentation (coverCount, checkCount, businessDays, etc). I'd want to make sure that the upper and lower limits of these are respected. I was able to test minimums but didn't have enough data to test the upper limits.
- Is it possible to see data for a range of businessDays? If so, I would definitely want to test that.



