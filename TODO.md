TODO:

Overall:
- add moving staff which fills with chords selected
- Add a small UI displaying the chord progression as it goes on and then clears after you reach the end of first chorus.
- Add UI element to show what section of song you are in A section, b section, verse, chorus etc.
- add all options for key logic for the song, double check transposition login
- AI for predicting chord changes
- implement key logic for db

Current Next Steps:

- dark and light mode adjustments for add your own page
- add your own page to json file
- dynamic text sizing in add song
- parse existing songs into the song creator so user can edit and make their own

Current Problem:

- parse both measure controllers into a json.
- we need to give all proper fields for song object so it can be properly parsed out later
- current issue to think about, how do we manage both controllers when inputing into json. Current
implementation has the following structure. measurecontroller 1 stores first two beats or whole beats, measure controller 2 stores second beat or none.

