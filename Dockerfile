FROM mcr.microsoft.com/dotnet/runtime:8.0-alpine AS base
LABEL stage=base
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
LABEL stage=build
WORKDIR /App
COPY "NuGet.Config" .
COPY "/source/GuaranteedSubscriber.csproj" .
RUN dotnet restore GuaranteedSubscriber.csproj
# Copy everything
 COPY "/source/" .
 RUN dotnet build "GuaranteedSubscriber.csproj" --verbosity q --configuration Release --runtime linux-x64 -o /App/build

FROM build AS publish
LABEL stage=publish
RUN dotnet publish "GuaranteedSubscriber.csproj" --verbosity q --configuration Release --output /App/publish /p:GenerateRuntimeConfigurationFiles=true --runtime linux-x64 --self-contained false

# Build runtime image
FROM base AS final
LABEL stage=final
COPY --from=publish /App/publish .
RUN mkdir -p /App/config
VOLUME [ "/App/config" ]
ENTRYPOINT ["dotnet", "GuaranteedSubscriber.dll"]