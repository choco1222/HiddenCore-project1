/**
 * 시계 그림 분석기 (클라이언트)
 * 
 * 채점 기준:
 * - 정상 시계: 2점 (원 + 시침/분침)
 * - 부분적: 1점 (원 또는 선만)
 * - 없음: 0점
 * 
 * 주의: 클라이언트에서는 OpenCV 사용 불가
 * → 기본 픽셀 분석 방식 사용
 * → 최종 채점은 서버(Java)에서 OpenCV로 수행
 */

class ClockDrawingAnalyzer {
    
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        this.width = canvas.width;
        this.height = canvas.height;
        this.centerX = this.width / 2;
        this.centerY = this.height / 2;
    }
    
    getClockScore() {
        const imageData = this.ctx.getImageData(0, 0, this.width, this.height);
        
        // 1. 그려진 정도 확인
        const complexity = this.calculateComplexity(imageData);
        console.log('복잡도:', complexity.toFixed(2) + '%');
        
        if (complexity < 2.0) {
            console.log('→ 너무 적게 그려짐');
            return 0;
        }
        
        // 2. 원형 패턴 탐지
        const hasCircle = this.detectCirclePattern(imageData);
        console.log('원 탐지:', hasCircle ? '있음' : '없음');
        
        // 3. 시침/분침 탐지
        const hasLines = this.detectLinesFromCenter(imageData);
        console.log('선 탐지:', hasLines ? '있음' : '없음');
        
        // 4. 점수 계산
        if (hasCircle && hasLines) {
            console.log('→ 클라이언트 예상: 2점 (정상 시계)');
            return 2;
        } else if (hasCircle || hasLines) {
            console.log('→ 클라이언트 예상: 1점 (부분적)');
            return 1;
        } else {
            console.log('→ 클라이언트 예상: 0점');
            return 0;
        }
    }
    
    /**
     * 원형 패턴 탐지
     * - 둘레 샘플링
     */
    detectCirclePattern(imageData) {
        const data = imageData.data;
        let circlePixels = 0;
        const expectedRadius = Math.min(this.width, this.height) / 2.5;
        
        // 원 둘레를 36개 지점으로 샘플링 (10도 간격)
        for (let angle = 0; angle < 360; angle += 10) {
            const rad = (angle * Math.PI) / 180;
            const x = Math.round(this.centerX + expectedRadius * Math.cos(rad));
            const y = Math.round(this.centerY + expectedRadius * Math.sin(rad));
            
            if (this.isPixelDrawn(data, x, y)) {
                circlePixels++;
            }
        }
        
        // 절반 그려졌으면 원으로 판단
        return circlePixels >= 18;
    }
    
    /**
     * 중심에서 바깥으로 향하는 선 탐지 (시침/분침 탐지 X)
     */
    detectLinesFromCenter(imageData) {
        const data = imageData.data;
        let linesFound = 0;
        
        // 여러 각도에서 중심에서 바깥으로 선이 있는지 확인 (30도 간격)
        for (let angle = 0; angle < 360; angle += 30) {
            const rad = (angle * Math.PI) / 180;
            let hasLine = false;
            
            // 중심에서 바깥쪽으로 스캔
            for (let r = 10; r < Math.min(this.width, this.height) / 3; r += 5) {
                const x = Math.round(this.centerX + r * Math.cos(rad));
                const y = Math.round(this.centerY + r * Math.sin(rad));
                
                if (this.isPixelDrawn(data, x, y)) {
                    hasLine = true;
                    break;
                }
            }
            
            if (hasLine) {
                linesFound++;
            }
        }
        
        // 12개 각도 중 2개 이상에서 선이 발견되면 시침/분침으로 판단
        return linesFound >= 2;
    }
    
    /**
     * 복잡도 계산 (전체 픽셀 중 그려진 비율)
     */
    calculateComplexity(imageData) {
        const data = imageData.data;
        let drawnPixels = 0;
        
        for (let i = 0; i < data.length; i += 4) {
            const alpha = data[i + 3];
            const red = data[i];
            
            // 투명하지 않고 흰색이 아니면 그려진 것
            if (alpha > 0 && red < 250) {
                drawnPixels++;
            }
        }
        
        return (drawnPixels / (this.width * this.height)) * 100;
    }
    
    /**
     * 특정 픽셀이 그려졌는지 확인
     */
    isPixelDrawn(data, x, y) {
        if (x < 0 || x >= this.width || y < 0 || y >= this.height) {
            return false;
        }
        
        const index = (y * this.width + x) * 4;
        const alpha = data[index + 3];
        const red = data[index];
        
        return alpha > 0 && red < 250;
    }
    
    /**
     * Canvas를 Base64 이미지로 변환
     */
    getImageData() {
        return this.canvas.toDataURL('image/png');
    }
}

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ClockDrawingAnalyzer;
}
