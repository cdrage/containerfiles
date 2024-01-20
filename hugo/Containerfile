# **Description:**
# My Hugo file for hosting my personal wiki / journal / etc.

FROM golang
RUN go install -mod=mod --tags extended github.com/gohugoio/hugo
VOLUME ["/src", "/dest"]
EXPOSE 1313
ENV HUGO_SRC /src
ENV HUGO_DEST /dest
ENV HUGO_THEME hugo-book
ENV HUGO_BUILD_DRAFT false
ENV HUGO_BASE_URL ""
ADD run-hugo /run-hugo
RUN chmod +x /run-hugo
ENTRYPOINT ["/run-hugo"]
CMD ["server", "--source=${HUGO_SRC}", "--theme=${HUGO_THEME}", "--buildDrafts=${HUGO_BUILD_DRAFT}", "--baseUrl=${HUGO_BASE_URL}", "--watch", "--destination=${HUGO_DEST}", "--appendPort=false"]
