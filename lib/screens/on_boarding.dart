import "package:flutter/material.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";
import "../network/local.dart";
class OnBoarding extends StatelessWidget{
  OnBoarding({super.key});
  final PageController _pageController = PageController();
  final List<String> _welcomes = <String>[
    "We will be happy to have you!",
    "Connect with the world with us.",
    "Introduce yourself to\nWASAT community."
  ];
  @override
  Widget build(final BuildContext context)
  => Stack(
    children: [
      Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: <TextButton>[
            TextButton(
              child: const Text("SKIP"),
              onPressed: ()=>_destructOnBoarding(context),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.arrow_forward_ios),
          onPressed: ()
          => _pageController.page!<2?
            _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut)
            :_destructOnBoarding(context)
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (final BuildContext context,final int i)
                  =>Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/on_boarding$i.png"
                      ),
                      Text(
                        _welcomes[i],
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      )
                    ],
                  )
                ),
              ),
              SmoothPageIndicator(
                controller: _pageController,
                count: 3,
                effect:ExpandingDotsEffect(
                  activeDotColor: Theme.of(context).primaryColor
                ),
              )
            ],
          ),
        )
      ),
      Container(
        width: MediaQuery.of(context).size.width*0.3,
        height: MediaQuery.of(context).size.height*0.15,      
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(MediaQuery.of(context).size.width*0.3)
          )
        ),
      )
    ],
  );
  void _destructOnBoarding(final BuildContext context){
    CacheHelper.prefs.setBool("on_boarding",false);
    Navigator.pushReplacementNamed(
      context,
      'login'
    );
  }
}