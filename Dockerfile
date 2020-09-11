FROM golang:alpine
ENV GO111MODULE=on
# Not sure why the two below commands are here... We can get by without them
# just fine, am I supposed to remove these? Leaving in...
RUN apk update --no-cache
RUN apk add git
# I've put ADD after the two above RUN commands, as any changes to files in ADD 
# would invalidate cache of RUNs that don't require the directory
# This means faster build times for each change to the app
ADD . /app
WORKDIR /app
RUN go build -o golang-test  .

# alpine:latest is super lightweight, as we've already built the go app in the 
# above container we can simply copy over the compiled app and run it in our
# final container without need for go installation, apk update and git install
FROM alpine:latest  
# EXPOSE is placed here as it's more static than dynamic content that follows.
EXPOSE 8000
WORKDIR /app
COPY --from=0 /app .
CMD ["/app/golang-test"] 

# Our image to deploy is 12.6MB rather than the original ~300MB