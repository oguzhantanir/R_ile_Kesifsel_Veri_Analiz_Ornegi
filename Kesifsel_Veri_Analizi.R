library(corrplot)   # Regresyon ilişkisi için martis karşılaştırma grafiği çizer

### 1.Adım: SENTETİK VERİ OLUŞTURMA 

#Tekrarlanabilirilik için tohum ekiyoruz(set.seed)
set.seed(123) 
## veri1: lineer ilişki içeren veri seti
# x1 için ortalaması 25 sapması 10 olan veri üretir 

n <- 100  #Gözlem Sayısı

veri1 <- data.frame( x1 = rnorm(n, mean = 25, sd = 10),  # Bağımsız değişken 
                     x2 = rnorm(n, mean = 30, sd = 5),   # Bağımsız değişken 
                     x3 = rnorm(n, mean = 10, sd = 20)   # Bağımsız değişken 
                     ) 

# Bağımlı değişken (x'lerden etkilenen, sabit değeri ve rastlantısal değer içeren stokastik bir 
# regresyon model yapısı kuruyoruz)
# Deterministik Model: Matematiksel Model (2 + 0.5*veri1$x1 + 2*veri1$x2 - 1.5*veri1$x3) sonucu tahmin edilebilen.
# Stokastik Model: istatistiksel Model (2 + 0.5*veri1$x1 + 2*veri1$x2 - 1.5*veri1$x3 + rnorm(n, mean = 0, sd = 0.5) sonucu istatistiksel yöntemlerle aranan.

veri1$yx <- 2 + 0.5*veri1$x1 + 2*veri1$x2 - 1.5*veri1$x3 + rnorm(n, mean = 0, sd = 0.5) # Bağımlı Değişken

## veri2: sayısal + kategorik 

veri2 <- data.frame( z1 = rnorm(n, mean = 40, sd = 16),  # Bağımsız değişken
                     z2 = rnorm(n, mean = 65, sd = 5),   # Bağımsız değişken
                     z3 = rnorm(n, mean = 15, sd = 35)   # Bağımsız değişken
                     ) 
# Bağımlı değişken 
veri2$yz <- 2*veri2$z1 + 3*veri2$z2 - 0.5*veri2$z3 + rnorm(n, mean = 0, sd = 3.5) # Bağımlı değişken

# ikinci veri setimize kategorik değişken de atayalım. 
veri2$kz <- sample(c("A","B","C"), n, replace = TRUE)   # Kategorik değişken

# Oluşturduğumuz veri setlerinin ilk 6 satırı ve başlıklarını görelim
head(veri1)
head(veri2)

# Verimiz sentetik ama analiz için yine de veri yapısına bakalım.
str(veri1)
str(veri2)  # Kategorik veri sütunu "chr" türünde.

### 2. Adım: EKSİK DEĞERLERİN KONTROLÜ

# Eksik veri tespiti yapalım, veride eksik olmadığını biliyoruz ama yöntemi görelim.
# Veri data frame olduğu için tek tek değişkenlere tespit yapmıyoruz.
colSums(is.na(veri1))
colSums(is.na(veri2))

# Deneme için bir veriyi NA yapalım.
veri1$x1[3] <- NA

# Tekrar NA kontrolü yapalım.
colSums(is.na(veri1))

### 3. Adım: - EKSİK DEĞERLERİN DOLDURULMASI

# Veri setimizde eksik veri çıkmadı ama çıksaydı ilgili sütun adını vererek
# mean (ortalama) değer ile doldurmak için aşağıdaki komut setini kullanacaktık.
veri1$x1[is.na(veri1$x1)] <- mean(veri1$x1, na.rm = TRUE)

# Tekrar NA kontrolü yapalım.
colSums(is.na(veri1))

# Ortalama ile doldurduğumuz veri x1 sütunu 3.sırada
head(veri1)

### 4. Adım: KATEGORİK DEĞİŞKENLERİN SAYISALA ÇEVRİLMESİ

# Hangi kategori değeri hangi sayıya denk geliyor sıralamadan anlıyoruz.
levels(as.factor(veri2$kz))

# Kategorik değerleri sayıya çeviriyoruz.
veri2$kz <- as.numeric(as.factor(veri2$kz))

# Kontrol edelim.
# Artık her iki veri setimizde numerik yapısında, analize başlamak için bir adım kaldı.
str(veri2)
head(veri2)

### 5. Adım: SAYISAL VERİLERİN STANDARDİZASYONU

# Standardizasyon bağımsız değişkenlere uygulanır.
# Örn; veri1'de x1, x2, ve x3 için standardizasyonu z-skoru ile yapabiliriz.
zskore_x1 <- scale(veri1$x1)
zskore_x2 <- scale(veri1$x2)
zskore_x3 <- scale(veri1$x3)
zskore_z1 <- scale(veri2$z1)
zskore_z2 <- scale(veri2$z2)
zskore_z3 <- scale(veri2$z3)

### 6. Adım: AYKIRI DEĞER TESPİTİ

# Alt ve Üst çeyreklikleri hesaplama
Q1 <- quantile(veri1$x1, 0.25) 
Q3 <- quantile(veri1$x1, 0.75) 

# Alt ve Üst sınırları hesaplama
IQR <- Q3 - Q1

lower_bound <- Q1 - 1.5 * IQR
upper_bound <- Q3 + 1.5 * IQR

# Aykırı değerleri belirleme
outliers <- veri1$x1[veri1$x1 < Q1 - 1.5*IQR | veri1$x1 > Q3 + 1.5*IQR] 

# Bulduğumuz değerleri ekrana yazdıralım
upper_bound
lower_bound
outliers

# Aykırı değer var ise boxplot grafiğinde de görünüyor olmalı
boxplot(veri1$x1, main="Aykırı Değerler")

# Aykırı değerin bulunduğu satırı bulalım
aykiri_satirlar <- which(veri1$x1 < lower_bound | veri1$x1 > upper_bound)
aykiri_satirlar

# Bulduğumuz aykırı değer 72.satırda, değerini NA yapalım 
veri1$x1[72] <- NA
# NA satırı Ortalama ile tekrar dolduralım
veri1$x1[is.na(veri1$x1)] <- mean(veri1$x1, na.rm = TRUE)
# Aykırı değer görünmüyor olmalı
boxplot(veri1$x1, main="Aykırı Değerler")

### 7. Adım: KORELASYON ANALİZİNİ YAPIYORUZ

# veri1 için korelasyon katsayısı hesaplama
cor_veri1 <- cor(veri1)
cor_veri1
# Korelasyon matrisini çizdiriyoruz
corrplot(cor_veri1, method = "color")

# veri2 için korelasyon katsayısı hesaplama
cor_veri2 <- cor(veri2)
cor_veri2
# Korelasyon matrisini çizdiriyoruz
corrplot(cor_veri2, method = "color")

### 8.Adım: ÇOKLU DOĞRUSAL REGRESYON MODELİ İLE İNCELİYORUZ

# Bağımsız değişkenlerin "x1, x2, x3" bağımlı değişkeni yordama gücünü inceliyoruz.
model_veri1 <- lm(yx ~ x1 + x2 + x3, data = veri1)
summary(model_veri1)

model_veri2 <- lm(yz ~ z1 + z2 + z3 + kz, data = veri2)
summary(model_veri2)



