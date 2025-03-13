# Movie & Trailer API  

This API fetches movies and trailers from [The Movie Database (TMDb)](https://www.themoviedb.org/).  
Three approaches were considered, with the third one being the final choice.  

## Approaches Considered  

### 1. Import Movies from a Daily File  
Uses a file generated daily by TMDb ([docs](https://developer.themoviedb.org/docs/daily-id-exports)) via a Rake task.  

#### ✅ Pros  
- Faster search by querying the local database instead of an external API.  
- Supports indexing and model validations.  

#### ❌ Cons  
- The file only contains movies (no translations).  
- Still requires API calls for trailer retrieval.  

### 2. Import Everything into the Database  
Imports all movies and their trailers from the API, returning them in a single request.  

#### ✅ Pros  
- No external API calls after the initial import.  
- Supports indexing and model validations.  
- Unified data retrieval.  

#### ❌ Cons  
- API rate limits apply.  
- 4-hour implementation constraint.  
- No support for translations.  

### 3. **(Chosen) Separate Endpoints for Movies & Trailers**  
Creates two endpoints that fetch data directly from TMDb, reducing redundant API calls.  

#### ✅ Pros  
- Fast implementation.  
- Supports multiple languages.  
- No need for a local database.  

#### ❌ Cons  
- Requires two separate requests (one for movies, one for trailers).  
- Slightly slower response time.  

## Implementation  

The API provides two endpoints:  

### 🎬 Fetch Movies  
```
GET http://localhost:3000/dept/v1/movies?query=<movie_name>&token=<your_token>&page=1&language=<lang>
```

### 🎬 Fetch Trailers
```
GET http://localhost:3000/dept/v1/movies/<movie_id>/trailers?token=<your_token>&page=1&language=<lang> -
- Returns only trailers hosted on Youtube or Vimeo
```

🔐 Security & OWASP Considerations
📌 Security Logging & Monitoring:
Errors are logged via the error_during_processing method.

🚫 Injection Protection:
Only permitted parameters are allowed, preventing injection attacks.

🔑 Authentication & Credentials Management:
API access requires a token.
Credentials are stored in a secrets file (use environment variables in production).

🛠️ Vulnerable & Outdated Components:
Controllers are tested by stubbing API responses.
External API calls are cached using VCR cassettes to avoid unnecessary requests during tests.
