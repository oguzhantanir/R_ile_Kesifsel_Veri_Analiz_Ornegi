## Temel Tanımlamalar;

**Veri:** Gözlem, ölçüm veya araştırmalar sonucunda elde edilen ham bilgilerdir. Sayısal, kategorik ya da metinsel biçimde olabilir ve tek başına anlamlı olmayabilir. Analiz edilerek bilgiye dönüştürülmesi gerekir.

**Bağımsız Değişken (Independent Variable):** Modelin açıklamaya veya tahmin etmeye çalıştığı çıktıyı belirlemede rol oynar ve genellikle manipüle edilebilir veya ölçülebilir niteliktedir.

**Bağımlı Değişken (Dependent Variable):** Bağımsız değişkenlerdeki değişimlerden etkilenir ve istatistiksel analizlerde sonuç değişkeni olarak kullanılır. Bu değişkenin davranışı, modelin doğruluğunu ve geçerliliğini belirleyen ana unsurdur.

**Aykırı Değer (Outlier):** Veri setindeki diğer gözlemlerden anlamlı derecede farklılık gösteren veri noktasıdır. Bu değerler, istatistiksel modellerin parametre tahminlerini ve dağılım varsayımlarını etkileyebilir. Aykırı değerler, genellikle veri setinin genel davranışını anlamak ve analiz sonuçlarını iyileştirmek için tespit edilir ve uygun yöntemlerle işlenir.

**Korelasyon (Correlation):** İki değişken arasındaki doğrusal ilişkinin yönünü ve şiddetini ölçen istatistiksel bir göstergedir. Korelasyon katsayısı -1 ile +1 arasında değişir; +1 tam pozitif ilişki, -1 tam negatif ilişki ve 0 doğrusal ilişki olmadığını ifade eder. Korelasyon analizi, değişkenler arasındaki bağı anlamak ve model kurarken ilişkileri değerlendirmek için kullanılır.

**Regresyon (Regression):** Bağımlı değişkenin bir veya daha fazla bağımsız değişken ile matematiksel olarak modellenmesi ve tahmin edilmesi yöntemidir. Lineer regresyonda amaç, gözlemler arasındaki doğrusal ilişkiyi en küçük kareler yöntemi ile tahmin etmek ve bağımsız değişkenlerin etkilerini ölçmektir. Regresyon analizi, veri üzerinde tahminler yapmak, ilişkileri anlamak ve istatistiksel çıkarımlar elde etmek için temel bir araçtır.

**Keşifsel Veri Analizi (Exploratory Data Analysis – EDA):** Veri setini özetlemek, yapısını anlamak ve içindeki desenleri ortaya çıkarmak amacıyla yapılan bir analiz sürecidir. Bu süreçte ortalama, medyan gibi özet istatistikler hesaplanır ve grafikler (histogram, boxplot vb.) kullanılarak veri görselleştirilir (IBM, t.y.).

## Uygulama Kodları ve Açıklamaları;

Korelasyon ilişkisi için martis karşılaştırma grafiği çizmek için gerekli kütüphaneyi yüklüyoruz. Kod da bulunan diğer fonksiyonlar için farklı bir kütüphane yüklemeye gerek duyulmuyor, R temel fonksiyonları içerisindeler.
```
library(corrplot)
```
**1.Adım: SENTETİK VERİ OLUŞTURMA**

Tekrarlanabilirilik için tohum ekiyoruz.
```
set.seed(123) 
```
İlk sentetik veri setimizi oluşturuyoruz. x1 için “ortalaması” 25, “sapma” 10 olan veri üretir, diğer bağımsız değişkenlerde benzer yöntem ile oluşturuluyor.
```
n <- 100  #Gözlem Sayısı
veri1 <- data.frame( x1 = rnorm(n, mean = 25, sd = 10),  # Bağımsız değişken 
                     x2 = rnorm(n, mean = 30, sd = 5),   		 # Bağımsız değişken 
                     x3 = rnorm(n, mean = 10, sd = 20)   		 # Bağımsız değişken 
                     ) 
```
Bağımlı değişken (x'lerden etkilenen, sabit değeri ve rastlantısal değer içeren stokastik bir regresyon model yapısı kuruyoruz)

**Deterministik Model:** Matematiksel Model de denir (2 + 0.5*veri1$x1 + 2*veri1$x2 - 1.5*veri1$x3) sonucu tahmin edilebilen.
**Stokastik Model:** istatistiksel Model de denir (2 + 0.5*veri1$x1 + 2*veri1$x2 - 1.5*veri1$x3 + rnorm(n, mean = 0, sd = 0.5)  ve sonuç istatistiksel yöntemlerle aranır.

Bağımlı Değişken oluşturup veri1 data frame’ine ekliyoruz
```
veri1$yx <- 2 + 0.5*veri1$x1 + 2*veri1$x2 - 1.5*veri1$x3 + rnorm(n, mean = 0, sd = 0.5)    
```

İkinci sentetik veri seti: veri2 (sayısal + kategorik) 
```
veri2 <- data.frame( z1 = rnorm(n, mean = 40, sd = 16),  	# Bağımsız değişken
                     z2 = rnorm(n, mean = 65, sd = 5),   	# Bağımsız değişken
                     z3 = rnorm(n, mean = 15, sd = 35)   	# Bağımsız değişken
                     ) 

veri2$yz <- 2*veri2$z1 + 3*veri2$z2 - 0.5*veri2$z3 + rnorm(n, mean = 0, sd = 3.5)   # Bağımlı değişken
```
ikinci veri setimize kategorik değişken de atayalım.
```
veri2$kz <- sample(c("A","B","C"), n, replace = TRUE)   	# Kategorik değişken
```
Oluşturduğumuz veri setlerinin ilk 6 satırı ve başlıklarını görelim
```
head(veri1)
head(veri2)
```
Verimiz sentetik ama analiz için yine de veri yapısına bakalım.
```
str(veri1)
str(veri2)  	# Kategorik veri "chr" türünde, diğerleri “num”
```
**2. Adım: EKSİK DEĞERLERİN KONTROLÜ**

Eksik veri tespiti yapalım, veri seti sentetik olduğu için eksik olmadığını biliyoruz ama yöntemi görelim. Veri, data frame olduğu için tek tek değişkenlere bakmamıza gerek yok.
```
colSums(is.na(veri1))
colSums(is.na(veri2))
```
Deneme için bir veriyi NA yapalım.
```
veri1$x1[3] <- NA
```
Tekrar NA kontrolü yapalım.
```
colSums(is.na(veri1))
```

**3. Adım: EKSİK DEĞERLERİN DOLDURULMASI**

Veri setimizde eksik veri çıkmadı ama çıksaydı ilgili sütun adını vererek ortalama (mean) değer ile doldurmak için aşağıdaki komut setini kullanacaktık.
```
veri1$x1[is.na(veri1$x1)] <- mean(veri1$x1, na.rm = TRUE)
```
Tekrar NA kontrolü yapalım.
```
colSums(is.na(veri1))
```
Ortalama ile doldurduğumuz veri x1 sütunu 3.sırada
```
head(veri1)
```
**4. Adım: KATEGORİK DEĞİŞKENLERİN SAYISALA ÇEVRİLMESİ**

Hangi kategori değeri hangi sayıya denk geliyor sıralamadan anlıyoruz.
```
levels(as.factor(veri2$kz))
```
Kategorik değerleri sayıya çeviriyoruz.
```
veri2$kz <- as.numeric(as.factor(veri2$kz))
```
Kontrol edelim, artık her iki veri setimizde numerik yapıda.
```
str(veri2)
head(veri2)
```

**5. Adım: SAYISAL VERİLERİN STANDARDİZASYONU**

Standardizasyonu bağımsız değişkenlere uyguluyoruz, uygulayacağımız modele göre bu değişebilir.
```
zskore_x1 <- scale(veri1$x1)
zskore_x2 <- scale(veri1$x2)
zskore_x3 <- scale(veri1$x3)
zskore_z1 <- scale(veri2$z1)
zskore_z2 <- scale(veri2$z2)
zskore_z3 <- scale(veri2$z3)
```
**6. Adım: AYKIRI DEĞER TESPİTİ**

Alt ve Üst çeyreklikleri “veri1” içerisindeki “x1” değişkeni için hesaplıyoruz, diğer değişkenler için de aynı yöntemi kullanacağız. Bu aykırı değerleri hesaplamamıza yardımcı olacak.
```
Q1 <- quantile(veri1$x1, 0.25) 
Q3 <- quantile(veri1$x1, 0.75) 
```
Alt ve Üst sınırları hesaplıyoruz.
```
IQR <- Q3 - Q1
lower_bound <- Q1 - 1.5 * IQR
upper_bound <- Q3 + 1.5 * IQR
```
Aykırı değerleri buluyoruz.
```
outliers <- veri1$x1[veri1$x1 < Q1 - 1.5*IQR | veri1$x1 > Q3 + 1.5*IQR] 
```
Bulduğumuz değerleri ekrana yazdıralım
```
upper_bound
lower_bound
outliers
```
Aykırı değer var ise boxplot grafiğinde de görünüyor olmalı, kontrol ediyoruz.
```
boxplot(veri1$x1, main="Aykırı Değerler")
```
Aykırı değerin bulunduğu satırı öğreniyoruz
```
aykiri_satirlar <- which(veri1$x1 < lower_bound | veri1$x1 > upper_bound)
aykiri_satirlar
```
Bulduğumuz aykırı değer 72.satırda, değerini NA yapalım.
```
veri1$x1[72] <- NA
```
NA satırı Ortalama (mean) ile tekrar dolduralım.
```
veri1$x1[is.na(veri1$x1)] <- mean(veri1$x1, na.rm = TRUE)
```
Aykırı değer artık görünmüyor olmalı, kontrol ediyoruz.
```
boxplot(veri1$x1, main="Aykırı Değerler")
```

**7. Adım: KORELASYON ANALİZİNİ YAPIYORUZ**

Korelasyon katsayılarını veri1 için hesaplıyoruz.
```
cor_veri1 <- cor(veri1)
cor_veri1
```
Korelasyon matrisini çizdiriyoruz
```
corrplot(cor_veri1, method = "color")
```
Korelasyon katsayılarını veri2 için hesaplıyoruz.
```
cor_veri2 <- cor(veri2)
cor_veri2
```
Korelasyon matrisini çizdiriyoruz
```
corrplot(cor_veri2, method = "color")
```

**8.Adım: ÇOKLU DOĞRUSAL REGRESYON MODELİ İLE İNCELİYORUZ**

Bağımsız değişkenlerin "x1, x2, x3" bağımlı değişkeni yordama gücünü inceliyoruz.
```
model_veri1 <- lm(yx ~ x1 + x2 + x3, data = veri1)
summary(model_veri1)
```
```
model_veri2 <- lm(yz ~ z1 + z2 + z3 + kz, data = veri2)
summary(model_veri2)
```

**Kaynakça:**
IBM. What is Exploratory Data Analysis?
https://www.ibm.com/topics/exploratory-data-analysis.html
