## Change Log

### [October 16, 2024](https://github.com/Stanford-Health/wearipedia-apple/commit/d2870be38000d2cfcf95b862ff4b42905e81a10d)
- created sample firebase project for a study, implemented uploading data to that firebase
- added functionality for clinician to choose start date for data to be fetched
- added funcitonality if enrolling in a study and seeing only your enrolled studies
- currently, enrolling in a study means being added to a clinician's firebase as a participant with all entries of specific data type (currently distanceWalkingRunning) uploaded to that firebase (from a specific start date)
- minor UI changes

### [September 27, 2024](https://github.com/Stanford-Health/wearipedia-apple/commit/cd259bd28cd71a2aae39352bc48b77ae8e3e9c17)
- minor UI additions
- renamed folders
- separated sign in and sign up

### [September 12, 2024](https://github.com/Stanford-Health/wearipedia-apple/commit/7776787437f6d9e09758eceb556af6149ee08f3e)

Added: 
1) storing whether a person signing in is a participant or a clinician
2) functionality to display and add study names and descriptions on clinician's end. clinician can only view their own studies
3) functionality for a participant to see all added studies (from all clinicians) in ParticipantStudyView

### [September 5, 2024](https://github.com/Stanford-Health/wearipedia-apple/commit/3e6c1315f538f8e70679e9c60b62bf1d27df6d65)

- Made generic functions to fetch and visualize data
- Account creation, sign in, and database upload functionality
- Uploaded initial project code
