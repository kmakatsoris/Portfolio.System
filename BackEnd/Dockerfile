# Use the official .NET Core SDK image as a base
FROM mcr.microsoft.com/dotnet/sdk:8.0  AS build
WORKDIR /api

# Copy csproj and restore as distinct layers
COPY *.csproj .
RUN dotnet restore

# Copy everything else and build the app
COPY . .
RUN dotnet publish -c Release -o out/net8.0

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0  AS runtime
WORKDIR /api
COPY --from=build ./api/out/net8.0/ .
EXPOSE 5000
ENTRYPOINT ["dotnet", "Portfolio.Core.dll"]
