---
authors:
- kogler
categories:
- Kotlin
- Android
date: 2016-04-15T12:15:15-06:00
short: |
 First impressions of Kotlin 
title: "Setting up Kotlin with Android and tests"
draft: false
---

최근에 저는 [Kotlin](https://kotlinlang.org/) 1.0 Beta 버전이 발표 되었다는 소식을 들었습니다. Kotlin 은 JVM과 Java, 그리고 Android 앱을 개발 하는데 사용 가능한 최신의 개발 언어입니다.

호기심이 동한 저는 Kotlin을 사용해서 샘플 Android 앱을 만들고 간단한 테스트를 해 보기로 작정했습니다. 


## 앱 설정하기 
Kotlin을 사용해서 Hello world 앱을 사용하는 것은 매우 쉬웠습니다. IntelliJ / Android 스튜디오를 위한 Kotlin 플러그인은 기존의 Java 코드를 Kotlin 코드로 변환해 주는 기능을 포함하고 있어서 매우 빠르게 시작할 수 있었습니다. 처음 시작할때 [여기](https://kotlinlang.org/docs/tutorials/kotlin-android.html)을 참조 하였습니다.

아래의 두가지에 주목 합시다. 

  1. Android Studio 를 시작하기 전 Kotlin 플러그인을 설치 했는지 확인합니다. 
  
  1. "Convert Java File to Kotlin File" 을 선택 후 변환 작업을 시작하기전, Java 파일을 하이라이트 할 필요가 있었습니다.
  

## Android 인스트루먼트 테스트 
간단한 테스트를 작성하는 것으로 작업을 시작했습니다. (Java와 Kotlin 파일을 하나의 프로젝트 안에서 혼용하더라도 문제 없이 동작하는 것으로 보입니다.) 
 
~~~kotlin
class MainActivityTest : ActivityInstrumentationTestCase2<MainActivity>(MainActivity::class.java) {
   private var mainActivity: Activity? = null

   @Throws(Exception::class)
   override fun setUp() {
       super.setUp()
       mainActivity = activity
   }

   fun test_itDisplaysHelloWorld() {
       val textView = mainActivity!!.findViewById(R.id.main_text) as TextView
       val actual = textView.text.toString()
       Assert.assertEquals("Hello World!", actual)
   }
}
~~~

파일을 변환하는 동안 한가지 문제가 있었는데, 바로 Android Studio의 테스트 runner 설정이 깨진것 입니다. 해결을 위해, Android Studio 에서 `Run -> Edit Configurations -> Android Tests` 로 진입하여 테스트 설정을 `android.test.InstrumentationTestRunner` 로 변경해야 했습니다. 
이 부분만 수정해 주면 별 문제 없이 Kotlin 을 사용한 테스트가 동작 했습니다. 


## Robolectric 테스트 
처음 수행했던 Android 인스투르먼트 테스트가 문제 없이 성공한 뒤에, Robolectric 테스트를 수행해 보기로 마음먹었습니다. 이 역시 별 문제 없이 잘 작동했으며, 아래의 코드는 Kotlin 을 사용한 Robolectric 테스트이고, 위에 진행했던 테스트와 동일합니다. 

~~~kotlin
@RunWith(RobolectricGradleTestRunner::class)
@Config(constants = BuildConfig::class)
class ExampleRobolectricTest {

    @Test
    fun itShouldDisplayHelloWorld() {
        val activity = Robolectric.setupActivity(MainActivity::class.java)
        val textView = activity.findViewById(R.id.main_text) as TextView

        assertThat(textView.text).isEqualTo("Hello World!")
    }
}
~~~


## Spek을 사용한 유닛 테스트 
[Spek](https://jetbrains.github.io/spek/) 은 rspec 과 유사한 형태의 문법을 사용한 Kotlin 기반 테스트 프레임웍 입니다. Spek 과 같은 도구를 찾고 있었던 저는 바로 사용해 보기로 했습니다. 
 
### 나쁜 소식 #1: Android Instrumentation test + Spek 
Spek 을 사용한 테스트를 사용하려면  `Spek` 베이스 클래스를 상속해야 할 필요가 있습니다. Android Instrument 테스트는 `InstrumentationTestCase` 클래스가 필요합니다. 제가 아는 바로는, 두개의 시스템을 한꺼번에 사용하도록 함으로서 문제가 됩니다. 

### 나쁜 소식 #2: Robolectric tests + Spek 
Robolectric 은 테스트를 위해 기본적으로 클래스 상속을 요구하지 않으며, 이는 이론 적으로는 Spek과 함께 적절하게 동작해야 합니다. 하지만 실제로는 기대한 대로 동작하지 않았는데, 문제는 테스트 런너가 테스트를 찾지 못했기 때문입니다. 아마도 원인은 
Robolectric 은 RobolectricTestRunner 에 의존성을 가지고 있는데 이는 `BlockJUnit4ClassRunner`(어노테이션에 기반해서 테스트를 찾아내는)의 확장이며, Spek은 그 나름대로의 `JUnitClassRunner` 와 함께 동작하기 때문인 것으로 보입니다. 

조만간 RobolectricSpek 테스트 런너에 대해 더 깊이 살펴볼 예정이긴 하지만, 현재로서는 두개가 한꺼번에 잘 동작하지는 않는것으로 보입니다. 

### 마지막으로, 좋은 소식 
위의 사례로 보았을때 Spek은 Android instrumatation 테스트나 Robolectric 테스트와 잘 동작하지 않지만, vanilla JUnit 테스트의 대체로서는 훌륭하게 동작합니다. 개인적으로 일반적인 Android 프로젝트에서 이는 매우 미심쩍은 도구로 생각하는데, 이는 JUnit 을 사용해서 코드를 테스트 하는 경우가 별로 없기 때문입니다. 다만, 이 글을 읽고 있는 여러분이 
만약 이런 테스트를 사용하고 있다면, 쉽게 Spek으로 변환할 수 있을것 입니다. 아래 간단한 Hello world 앱 테스트 코드가 있으므로 참고 해 보세요. 

~~~kotlin
import org.jetbrains.spek.api.Spek
import kotlin.test.assertEquals

class ExampleUnitTest : Spek() {
    init {
        given("Two numbers") {
            val firstNumber = 3
            val secondNumber = 5
            on("adding the numbers") {
                val result = firstNumber + secondNumber
                it("should return the correct sum") {
                    assertEquals(8, result)
                }
            }
        }
    }
}
~~~

## 결론 
Kotlin 은 기본의 Java 를 그대로 사용하는 것 보다는 훨씬 좋은 언어인것 같습니다. "Hello World" Android 앱을 설정하는 것은 매우 쉬웠으며, Android Instrumentation 테스트와 Robolectric 테스트 모두 쉽게 구성할 수 있었습니다. 
앞으로도 더 사용해 보아야 겠는걸요? 

번역: 정윤진 (yjeong@pivotal.io) 


Demo for AmorePacific 
add concourse 


