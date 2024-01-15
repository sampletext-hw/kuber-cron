using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Hosting;

var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

// Define the GET endpoint for fetching and saving Google's homepage
app.MapGet("/fetch", async () =>
{
    try
    {
        // Download Google's homepage
        string googleHomepage = await DownloadGoogleHomepage();

        // Save the content to a file
        await File.WriteAllTextAsync("google_homepage.html", googleHomepage);

        return Results.Ok("Google homepage downloaded successfully.");
    }
    catch (Exception ex)
    {
        return Results.StatusCode(StatusCodes.Status500InternalServerError);
    }
});

await app.RunAsync();

async Task<string> DownloadGoogleHomepage()
{
    using HttpClient httpClient = new HttpClient();

    // Download Google's homepage
    HttpResponseMessage response = await httpClient.GetAsync("https://www.google.com");

    // Ensure the request was successful
    response.EnsureSuccessStatusCode();

    // Read the content
    return await response.Content.ReadAsStringAsync();
}