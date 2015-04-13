(function($) {

    $.fn.instagram = function(options) {

        //current avaliable options (would like add in different api calling abilities)
        var settings = $.extend({
            apiKey: '',
            names: '',
            tag: '',
            count: 2,
            apiCalls: 1,
            minNumber: 2,
            target: this,
            fullscreen: true,
            after: '',
            loader: '',
            addmore: '',
            tag_only: false,
            responsive: true,
            container: true,
            container_number: 4,
            container_class: 'grid',
            class: 'grid__item one-quarter lap-one-half palm-one-whole'
        }, options);

        if (matchMedia('only screen and (max-width: 480px)').matches && settings.responsive === true) {
            settings.count = 1;
            settings.minNumber = 1;
        }
        //need variables for funciton and api calls
        var system = $.extend({
            loadedAssets: 0,
            page: 0,
            userAssets: 0,
            isLoading: false,
            searchUsers: false,
            loadedAssets: 0,
            searched: [],
            content: [],
            lastName: settings.names[settings.names.length - 1],
            builtItems: 0
        });


        //helper functions
        /**
         * Loads more data from the API.
         */
        function loadMore(event) {
            if (!system.isLoading) {
                loadData()
            }
        };

        /**
         * Loads data from the API.
         */
        function loadData() {
            system.isLoading = true;

            $.ajax({
                url: system.apiURL,
                dataType: 'jsonp',
                success: onLoadData
            });

        };

        /**
         * Builds play and pause button for movies
         */
        function play_pause(event) {
            video = event.target.previousSibling

            button = event.target
            if (video.paused == true) {
                // $('body > *').find('video').not(video).pause()

                //Play the video
                video.play();
                //Change to pause button
                $(button).removeClass('play').addClass('pause');

                if (settings.fullscreen) {
                    if (video.requestFullscreen) {
                        video.requestFullscreen();
                    } else if (video.mozRequestFullScreen) {
                        video.mozRequestFullScreen(); // Firefox
                    } else if (video.webkitRequestFullscreen) {
                        video.webkitRequestFullscreen(); // Chrome and Safari
                    }
                }
            } else {
                video.pause();
                //Change to play button
                $(button).removeClass('pause').addClass('play');
            }
        };

        /**
         * Simple compare function for date sorting
         */
        function compare(a, b) {
            var date2 = new Date(parseInt(a.created_time) * 1000),
                date1 = new Date(parseInt(b.created_time) * 1000);

            if (date1 < date2)
                return -1;
            if (date1 > date2)
                return 1;
            return 0;
        };

        /**
         * Waits till images has loaded before showing elements REQUIRES IMAGESLOADED PLUGIN
         */
        function applyLayout() {


            $(settings.target).imagesLoaded(function() {

                $(settings.target).find('.assets').css('display', 'inline-block').fadeIn('slow');
                settings.loader.fadeOut('normal');
                // console.timeEnd('instatimer')

                settings.after()

            });

        };

        /**
         * JSON parsing function
         */
        function onLoadData(data) {
            system.isLoading = false;
            // Increment page index for future calls.
            system.page++;
            //iterate through each photo
            $.each(data.data, function(i, val) {

                var tags = val.tags.indexOf(settings.tag)
                //check for matching tag or if tags set
                if (tags != "-1" || settings.tag === '') {
                    //keep count for limiting calls
                    system.loadedAssets++

                    //keep count of user loaded assets
                    system.userAssets++

                    //send each photo to content array
                    system.content.push(val)
                }
            });

            //if user has more to find
            if (system.userAssets < settings.minNumber && system.page <= settings.apiCalls) {
                system.apiURL = data.pagination.next_url;
                searchUser(searching);
            }


            //if finished with the user (either found number or maxed out calls)
            if (system.userAssets >= settings.minNumber || system.page > settings.apiCalls) {


                system.searched.push(searching);
                //reset userAssets
                system.userAssets = 0;
                //reset page count
                system.page = 0;

                if (!settings.tag_only) {
                    //call next user
                    searchUser(searching);
                } else {
                    if (system.content.length === 0) {
                        console.log('no images found');
                    }

                    system.content.sort(compare);
                    //render objects to the DOM
                    buildAllthethings(system.content);
                }



                //see if reached last user to call build out
                if (data.data[0].user.id === system.lastName) {
                    // Now let's sort the dates in descending order and output the results.
                    if (system.content.length === 0) {
                        console.log('no images found');
                    }

                    system.content.sort(compare);
                    //render objects to the DOM
                    buildAllthethings(system.content);
                }
            }
        };

        /**
         * Build objects and add to the DIM
         */
        function buildAllthethings(content) {
            //iterate through each image
            $.each(system.content, function(i, val) {
                // console.log(val)
                //see if photo
                if (matchMedia('only screen and (max-width: 480px)').matches && settings.responsive === true && system.builtItems === settings.container_number - 1) {
                    return false
                } else {
                    if (val.type === "image") {

                        var photo = $('<img />', {
                            "src": val.images.standard_resolution.url
                        }),
                            description = $('<p />', {}).text(val.caption.text.substring(0, 100)),
                            description_container = $('<div />', {
                                'class': 'insta_caption'
                            }).append(description),
                            link = $('<a />', {
                                "href": val.link,
                                "class": 'instagram_objects',
                                "rel": "instagram",
                                "title": val.caption.text,
                                "data-username": val.user.username,
                                "data-likes": val.likes.count,
                                "data-comments": val.comments.count
                            }).append(photo, description_container),
                            handle_img = $('<img />', {
                                'class': 'instgram_picture',
                                src: val.caption.from.profile_picture
                            }),
                            handle_text = $('<a />', {
                                'class': 'handle',
                                text: "@" + val.user.username
                            }),
                            handle = $('<a />', {

                                'href': "http://instagram.com/" + val.user.username

                            }).append(handle_img, handle_text),
                            post = $('<p />', {
                                'class': 'instagram_text',
                                text: val.caption.text
                            }),
                            assets = $('<div />', {
                                "class": 'assets photo ' + settings.class
                            }).append(link, handle, post).hide();




                        if (settings.container) {

                            if (system.builtItems != 0) {

                                settings.target.children('.grid').last().append(assets)

                                if (system.builtItems === (settings.container_number - 1)) {
                                    system.builtItems = 0

                                } else {
                                    system.builtItems++
                                }



                            } else {

                                container = $('<div />', {
                                    "class": 'container ' + settings.container_class
                                }).append(assets).appendTo(settings.target)
                                system.builtItems++
                            }

                        }

                        // Add image HTML to the page.
                        // settings.target.append(assets);
                    }

                    // see if video
                    if (val.type === "video") {
                        var video = $('<video />', {
                            "src": val.videos.standard_resolution.url,
                            "type": "video/mp4",
                            'width': '100%',
                            "controls": false,
                            "data-username": val.user.username,
                            "data-likes": val.likes.count,
                            "data-comments": val.comments.count
                        }),
                            video_controls = $('<div />', {
                                "type": "button",
                                "class": "play control"
                            }),
                            description = $('<p />', {}).text(val.caption.text.substring(0, 100)),
                            description_container = $('<div />', {
                                'class': 'insta_caption'
                            }).append(description),
                            video_container = $('<div />', {
                                'class': 'video_container'
                            }).append(video, video_controls),
                            assets = $('<div />', {
                                "class": 'assets photo ' + settings.class
                            }).append(video_container, description_container).hide();
                        // Add image HTML to the page.
                        // settings.target.append(assets)
                        if (settings.container) {

                            if (system.builtItems != 0) {

                                settings.target.children('.grid').last().append(assets)

                                if (system.builtItems === (settings.container_number - 1)) {
                                    system.builtItems = 0

                                } else {
                                    system.builtItems++
                                }

                            } else {

                                container = $('<div />', {
                                    "class": 'container ' + settings.container_class
                                }).append(assets).appendTo(settings.target)
                                system.builtItems++
                            }

                        }
                    }
                }


            })

            //callback function
            applyLayout()
        };

        /**
         * Routing fuction for searching each user
         */
        function searchUser(name) {

            if (system.searched.indexOf(name) === -1 || settings.tag_only) {
                searching = name;

                loadMore()
            }

            if (system.searched.indexOf(name) != -1 && !settings.tag_only) {
                system.searchingUsers = false;
                searchUsers()
            }
        };

        /**
         * Search all of the users
         */
        function searchUsers() {

            $.each(settings.names, function(i, val) {
                //check to see if searching a user or if searched before

                if (!system.searchingUsers && system.searched.indexOf(val) === -1) {

                    system.searchingUsers = true
                    //set new api call
                    if (!settings.tag_only) {
                        system.apiURL = "https://api.instagram.com/v1/users/" + val + "/media/recent/?count=" + settings.count + "&access_token=" + settings.apiKey;
                        //search this users
                        searchUser(val);
                    } else {
                        system.apiURL = "https://api.instagram.com/v1/tags/" + settings.tag + "/media/recent/?count=" + settings.count + "&access_token=" + settings.apiKey;
                        searching = name;
                        loadMore()
                    }

                }
            })
        };


        /**
         * Check if loader and pagination button exist
         */
        function pluginhelpers() {
            //check for loader
            if (settings.loader.length == 0) {
                //create loader element and add to container
                loader = $('<div />', {
                    'id': 'loader'
                })
                settings.target.append(loader);
                settings.loader = loader;
            }
            // if (settings.addmore.length == 0) {
            //     //create loader element and add to container
            //     addmore = $('<div />', {
            //       'id': 'addmore'
            //     })
            //     settings.target.append(addmore);
            //     settings.addmore = addmore;
            // }

            // //bind addmore to further calls
            // settings.addmore.bind('click', loadMore)

            //bind controls to videos
            settings.target.on('click', '.control', play_pause);
        }


        //for testing...start clock!
        // console.time('instatimer');
        //make sure helpers exist
        pluginhelpers();
        //start function
        searchUsers();
    };

})(jQuery);