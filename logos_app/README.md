# Event

Event is a user-friendly app designed to help people create and manage campaigns for various celebrations, such as weddings, baby showers, housewarming parties, and more. With intuitive features and customizable options, Event makes planning and organizing events a breeze, ensuring every celebration is memorable and stress-free. 🎉

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Standards

- Configure your IDE for a maximum of 110 characters per line;
- Use single quotes for strings only;

## Architecture

This project follows the Architecting Flutter apps, having the UI Layer containing the Views and ViewModels and the Data Layer containing the Models (Repository, Service).

**Views**  
In the Views, the contained logic includes: Simple ifs to show widgets based on flags or nullable fields; animation logic; layout logic based on device information, such as size and orientation; simple routing logic.

**View Models**  
The ViewModels retrieve data from repositories and transform it into a valid format for display, for example, filtering, aggregating, sorting, or ordering data; Maintain the necessary states for display, so there is no data loss; Expose callback returns.

**Repositories**  
In the repositories, the responsibilities are to fetch data from services and transform the raw data obtained into domain models. The business logic associated with services is in the repositories, such as: Cache, error handling, retry logic, data updating, and all functions for data requests to be manipulated by the ViewModels.

**Services**  
This is the lowest layer of the application and encapsulates the API endpoints and exposes asynchronous response objects, containing only data loading and not maintaining any state.

**UseCases**  
UseCases should only be used when logic repetition is noticed in the ViewModels, avoiding the creation of UseCases for simpler locic.

- [For more information, consult the Flutter documentation](https://docs.flutter.dev/app-architecture/guide)
